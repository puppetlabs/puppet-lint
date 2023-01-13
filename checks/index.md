---
layout: default
---

# Checks

---

Click on any of the following error messages to learn more about the check and
how to resolve it.

### Spacing, Indentation & Whitespace

 * ["two-space soft tabs not used"](/puppet-lint/checks/2sp_soft_tabs/)
 * ["tab character found"](/puppet-lint/checks/hard_tabs/)
 * ["trailing whitespace found"](/puppet-lint/checks/trailing_whitespace/)
 * ["line has more than 80 characters"](/puppet-lint/checks/80chars/)
 * ["line has more than 140 characters"](/puppet-lint/checks/140chars/)
 * ["=> is not properly aligned"](/puppet-lint/checks/arrow_alignment/)

### Comments

 * ["// comment found"](/puppet-lint/checks/slash_comments/)
 * ["/\* \*/ comment found"](/puppet-lint/checks/star_comments/)

### Quoting

 * ["double quoted string containing no variables"](/puppet-lint/checks/double_quoted_strings/)
 * ["variable not enclosed in {}"](/puppet-lint/checks/variables_not_enclosed/)
 * ["string containing only a variable"](/puppet-lint/checks/only_variable_string/)
 * ["single quoted string containing a variable found"](/puppet-lint/checks/single_quote_string_with_variables/)
 * ["quoted boolean value found"](/puppet-lint/checks/quoted_booleans/)
 * ["puppet:// URL without modules/ found"](/puppet-lint/checks/puppet_url_without_modules/)

### Resources

 * ["unquoted resource title"](/puppet-lint/checks/unquoted_resource_title/)
 * ["ensure found on line but it's not the first attribute"](/puppet-lint/checks/ensure_first_param/)
 * ["symlink target specified in ensure attr"](/puppet-lint/checks/ensure_not_symlink_target/)
 * ["mode should be represented as a 4 digit octal value or symbolic mode"](/puppet-lint/checks/file_mode/)
 * ["unquoted file mode"](/puppet-lint/checks/unquoted_file_mode/)
 * ["duplicate parameter found in resource"](/puppet-lint/checks/duplicate_params/)

### Conditionals

 * ["selector inside resource block"](/puppet-lint/checks/selector_inside_resource/)
 * ["case statement without a default case"](/puppet-lint/checks/case_without_default/)

### Classes

 * ["foo::bar not in autoload module layout"](/puppet-lint/checks/autoloader_layout/)
 * ["right-to-left (<-) relationship"](/puppet-lint/checks/right_to_left_relationship/)
 * ["class defined inside a class"](/puppet-lint/checks/nested_classes_or_defines/)
 * ["define defined inside a class"](/puppet-lint/checks/nested_classes_or_defines/)
 * ["class inherits across namespaces"](/puppet-lint/checks/inherits_across_namespaces/)
 * ["optional parameter listed before required parameter"](/puppet-lint/checks/parameter_order/)
 * ["class inheriting from params class"](/puppet-lint/checks/class_inherits_from_params_class/)
 * ["foo::bar-baz contains a dash"](/puppet-lint/checks/names_containing_dash/)
 * ["arrow should be on right operand's line"](/puppet-lint/checks/arrow_on_right_operand_line/)

### Variables

 * ["variable is lowercase"](/puppet-lint/checks/variable_is_lowercase/)
 * ["variable contains a dash"](/puppet-lint/checks/variable_contains_dash/)
 * ["top-scope variable being used without an explicit namespace"](/puppet-lint/checks/variable_scope/)

### Documentation

 * ["foo::bar not documented"](/puppet-lint/checks/documentation/)

### Nodes

 * ["unquoted node name found"](/puppet-lint/checks/unquoted_node_name/)
