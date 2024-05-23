# Public: A puppet-lint custom check to detect deprecated functions.
DEPRECATED_FUNCTIONS_VAR_TYPES = Set[:FUNCTION_NAME]

# These functions have been deprecated in stblib and will impact puppet upgrades
# between puppet 7 and puppet 8.
EASY_FUNCTIONS = [
  'strip', 'rstrip', 'getvar', 'sort', 'upcase', 'round', 'chop', 'chomp',
  'ceiling', 'capitalize', 'cammelcase', 'is_array', 'cod',
  'min', 'max', 'lstrip', 'hash', 'has_key', 'downcase', 'abs', 'dig',
  'dig44', 'unique'
].freeze

PuppetLint.new_check(:deprecated_functions) do
  def check
    tokens.select { |x| DEPRECATED_FUNCTIONS_VAR_TYPES.include?(x.type) }.each do |token|
      next unless EASY_FUNCTIONS.include?(token.value)

      notify :warning, {
        message: "Deprecated Function Found: '#{token.value}'",
        line: token.line,
        column: token.column,
        token: token,
        fact_name: token.value
      }
    end
  end
end
