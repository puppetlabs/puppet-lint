# Public: Check the class or defined type comments for a multitude of conventions and record a warning
# if the convention isn't agreed upon
PuppetLint.new_check(:advanced_doc_comments) do
  def check
    PuppetLint.configuration.add_option('check_config')

    return if PuppetLint.configuration.check_config.nil?
    return unless PuppetLint.configuration.check_config.key?(:advanced_doc_comments)
    ruleset = JSON.load_file(PuppetLint.configuration.check_config[:advanced_doc_comments])

    (class_indexes + defined_type_indexes).each do |item_idx|
      comment_token = find_comment_token(item_idx[:tokens].first)
      next if comment_token.nil?

      first_token = item_idx[:tokens].first

      comment = get_comment(comment_token)
      code = get_code(first_token)
      type = if first_token.type == :CLASS
               'class'
             else
               'defined type'
             end

      ruleset.each do |rule_name, rule|
        condition = Regexp.new(
          rule.key?('condition') ? rule['condition'] : '.+', Regexp::MULTILINE | Regexp::IGNORECASE
        )
        comment_condition = Regexp.new(
          rule.key?('comment-condition') ? rule['comment-condition'] : '.+', Regexp::MULTILINE | Regexp::IGNORECASE
        )
        check = Regexp.new(rule['check'], Regexp::MULTILINE | Regexp::IGNORECASE)

        next unless condition.match?(code)
        next unless comment_condition.match?(code)
        next if check.match?(comment)

        notify(
          :warning,
          :message => "Advanced doc comments rule #{rule_name} failed on #{type}",
          :line => first_token.line,
          :column => first_token.column
        )
      end
    end
  end

  # Get the full comment text
  def get_comment(start_token)
    text = start_token.value
    next_token = start_token.next_token
    while (COMMENT_TOKENS + WHITESPACE_TOKENS).include?(next_token.type)
      text += next_token.value
      next_token = next_token.next_token
    end
    text
  end

  # Get the full class or type code. Expects to start with the CLASS or TYPE token
  def get_code(start_token)
    code = start_token.value
    brace_depth = 0
    next_token = start_token.next_token
    until next_token.nil?
      code += next_token.value
      brace_depth += 1 if next_token.type == :LBRACE
      brace_depth -= 1 if next_token.type == :RBRACE
      break if brace_depth.zero? && next_token.type == :RBRACE
      next_token = next_token.next_token
    end
    code
  end
end
PuppetLint.configuration.send('advanced_doc_comments_supports_config')
