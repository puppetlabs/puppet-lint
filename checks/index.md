---
layout: default
---

# Checks

---

Click on any of the following error messages to learn more about the check and
how to resolve it.

### Spacing, Indentation & Whitespace

 * ["two-space soft tabs not used"]({{ site.baseurl }}/checks/2sp_soft_tabs/)
 * ["tab character found"]({{ site.baseurl }}/checks/hard_tabs/)
 * ["trailing whitespace found"]({{ site.baseurl }}/checks/trailing_whitespace/)
 * ["line has more than 80 characters"]({{ site.baseurl }}/checks/80chars/)
 * ["line has more than 140 characters"]({{ site.baseurl }}/checks/140chars/)
 * ["=> is not properly aligned"]({{ site.baseurl }}/checks/arrow_alignment/)

### Comments

 * ["// comment found"]({{ site.baseurl }}/checks/slash_comments/)
 * ["/\* \*/ comment found"]({{ site.baseurl }}/checks/star_comments/)

### Quoting

 * ["double quoted string containing no variables"]({{ site.baseurl }}/checks/double_quoted_strings/)
 * ["variable not enclosed in {}"]({{ site.baseurl }}/checks/variables_not_enclosed/)
 * ["string containing only a variable"]({{ site.baseurl }}/checks/only_variable_string/)
 * ["single quoted string containing a variable found"]({{ site.baseurl }}/checks/single_quote_string_with_variables/)
 * ["quoted boolean value found"]({{ site.baseurl }}/checks/quoted_booleans/)
 * ["puppet:// URL without modules/ found"]({{ site.baseurl }}/checks/puppet_url_without_modules/)

### Resources

 * ["unquoted resource title"]({{ site.baseurl }}/checks/unquoted_resource_title/)
 * ["ensure found on line but it's not the first attribute"]({{ site.baseurl }}/checks/ensure_first_param/)
 * ["symlink target specified in ensure attr"]({{ site.baseurl }}/checks/ensure_not_symlink_target/)
 * ["mode should be represented as a 4 digit octal value or symbolic mode"]({{ site.baseurl }}/checks/file_mode/)
 * ["unquoted file mode"]({{ site.baseurl }}/checks/unquoted_file_mode/)
 * ["duplicate parameter found in resource"]({{ site.baseurl }}/checks/duplicate_params/)

### Conditionals

 * ["selector inside resource block"]({{ site.baseurl }}/checks/selector_inside_resource/)
 * ["case statement without a default case"]({{ site.baseurl }}/checks/case_without_default/)

### Classes

 * ["foo::bar not in autoload module layout"]({{ site.baseurl }}/checks/autoloader_layout/)
 * ["right-to-left (<-) relationship"]({{ site.baseurl }}/checks/right_to_left_relationship/)
 * ["class defined inside a class"]({{ site.baseurl }}/checks/nested_classes_or_defines/)
 * ["define defined inside a class"]({{ site.baseurl }}/checks/nested_classes_or_defines/)
 * ["class inherits across namespaces"]({{ site.baseurl }}/checks/inherits_across_namespaces/)
 * ["optional parameter listed before required parameter"]({{ site.baseurl }}/checks/parameter_order/)
 * ["class inheriting from params class"]({{ site.baseurl }}/checks/class_inherits_from_params_class/)
 * ["foo::bar-baz contains a dash"]({{ site.baseurl }}/checks/names_containing_dash/)
 * ["arrow should be on right operand's line"]({{ site.baseurl }}/checks/arrow_on_right_operand_line/)

### Variables

 * ["variable is lowercase"]({{ site.baseurl }}/checks/variable_is_lowercase/)
 * ["variable contains a dash"]({{ site.baseurl }}/checks/variable_contains_dash/)
 * ["top-scope variable being used without an explicit namespace"]({{ site.baseurl }}/checks/variable_scope/)

### Documentation

 * ["foo::bar not documented"]({{ site.baseurl }}/checks/documentation/)

### Nodes

 * ["unquoted node name found"]({{ site.baseurl }}/checks/unquoted_node_name/)
