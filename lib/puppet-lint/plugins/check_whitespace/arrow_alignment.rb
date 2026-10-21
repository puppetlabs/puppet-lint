# frozen_string_literal: true

# Public: Check the manifest tokens for any arrows (=>) in a grouping ({}) that
# are not aligned with other arrows in that grouping.

# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace

COMMENT_TYPES = Set[:COMMENT, :SLASH_COMMENT, :MLCOMMENT]

# rubocop:disable Metrics/BlockLength
PuppetLint.new_check(:arrow_alignment) do
  def check
    initialize_state

    tokens_to_check = tokens.reject do |token|
      COMMENT_TYPES.include?(token.type)
    end

    tokens_to_check.each do |token|
      case token.type
      when :FARROW
        handle_farrow(token)
      when :LBRACE
        handle_lbrace
      when :RBRACE, :SEMIC
        process_alignment(token)
        handle_block_exit(token)
      end
    end
  end

  def fix(problem)
    if problem[:newline]
      fix_newline_alignment(problem)
    else
      fix_horizontal_alignment(problem)
    end
  end

  private

  def initialize_state
    @arrow_column = [0]
    @level_idx = 0
    @level_tokens = []
    @param_column = [nil]
  end

  def handle_lbrace
    @level_idx += 1
    @arrow_column[@level_idx] = 0
    @level_tokens[@level_idx] = []
    @param_column[@level_idx] = nil
  end

  def handle_block_exit(token)
    @arrow_column[@level_idx] = 0
    @level_tokens[@level_idx].clear
    @param_column[@level_idx] = nil
    @level_idx -= 1 if token.type == :RBRACE
  end

  def handle_farrow(token)
    param_token = token.prev_code_token
    p_len, p_col = calculate_param_details(param_token)

    @param_column[@level_idx] ||= p_col

    # Determine where arrow should be relative to its own line or the group
    current_tokens = (@level_tokens[@level_idx] ||= [])
    this_arrow_column = if current_tokens.any? { |t| t.line == token.line }
                          @param_column[@level_idx] + p_len + 1
                        else
                          param_token.column + param_token.to_manifest.length + 1
                        end

    @arrow_column[@level_idx] = this_arrow_column if @arrow_column[@level_idx] < this_arrow_column
    @level_tokens[@level_idx] << token
  end

  def calculate_param_details(param_token)
    if param_token.type == :DQPOST
      len = 0
      iter = param_token
      until iter.type == :DQPRE
        len += iter.to_manifest.length
        iter = iter.prev_token
      end
      [len + iter.to_manifest.length, iter.column]
    else
      [param_token.to_manifest.length, param_token.column]
    end
  end

  def process_alignment(_token)
    current_tokens = @level_tokens[@level_idx] || []
    return unless current_tokens.map(&:line).uniq.length > 1
    return if current_tokens.size < 2

    target_col = @arrow_column[@level_idx]

    current_tokens.each do |arrow_tok|
      next if arrow_tok.column == target_col

      trigger_notification(arrow_tok, target_col)
    end
  end

  def trigger_notification(arrow_tok, target_col)
    arrows_on_line = @level_tokens[@level_idx].select { |t| t.line == arrow_tok.line }

    notify(
      :warning,
      message: 'indentation of => is not properly aligned ' \
               "(expected in column #{target_col}, but found " \
               "it in column #{arrow_tok.column})",
      line: arrow_tok.line,
      column: arrow_tok.column,
      token: arrow_tok,
      arrow_column: target_col,
      newline: arrows_on_line.index(arrow_tok) != 0,
      newline_indent: @param_column[@level_idx] - 1,
    )
  end

  def fix_newline_alignment(problem)
    index = tokens.index(problem[:token].prev_code_token.prev_token)
    tokens.insert(index, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))

    prev_token = problem[:token].prev_code_token.prev_token
    prev_token.type = :INDENT
    prev_token.value = ' ' * problem[:newline_indent]

    end_idx = tokens.index(problem[:token].prev_code_token)
    start_token = problem[:token].prev_token_of([:INDENT, :NEWLINE])
    start_idx = tokens.index(start_token)

    param_length = tokens[start_idx..end_idx].sum { |r| r.to_manifest.length } + 1
    apply_whitespace_fix(problem, problem[:arrow_column] - param_length)
  end

  def fix_horizontal_alignment(problem)
    current_ws = 0
    current_ws = problem[:token].prev_token.to_manifest.length if problem[:token].prev_token.type == :WHITESPACE

    new_len = current_ws + (problem[:arrow_column] - problem[:token].column)
    apply_whitespace_fix(problem, new_len)
  end

  def apply_whitespace_fix(problem, new_ws_len)
    raise PuppetLint::NoFix if new_ws_len.negative?

    new_ws_value = ' ' * new_ws_len
    if problem[:token].prev_token.type == :WHITESPACE
      problem[:token].prev_token.value = new_ws_value
    else
      index = tokens.index(problem[:token].prev_token)
      tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:WHITESPACE, new_ws_value, 0, 0))
    end
  end
end
# rubocop:enable Metrics/BlockLength
