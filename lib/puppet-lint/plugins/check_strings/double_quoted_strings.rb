# Public: Check the manifest tokens for any double quoted strings that don't
# contain any variables or common escape characters and record a warning for
# each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#quoting
ESCAPE_CHAR_RE = %r{(\\\$|\\"|\\'|'|\r|\t|\\t|\\s|\n|\\n|\\\\)}

PuppetLint.new_check(:double_quoted_strings) do
  def check
    invalid_tokens = tokens.select do |token|
      token.type == :STRING &&
        token.value.gsub(' ' * token.column, "\n")[ESCAPE_CHAR_RE].nil?
    end

    invalid_tokens.each do |token|
      notify(
        :warning,
        message: 'double quoted string containing no variables',
        line: token.line,
        column: token.column,
        token:,
        description: 'Check the manifest tokens for any double quoted strings that don\'t ' \
                     'contain any variables or common escape characters and record a warning for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#quoting',
      )
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end
