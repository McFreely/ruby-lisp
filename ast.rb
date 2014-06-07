require_relative 'types'

# This module contains a few simple helper functions
# for checking the type os ASTs

def is_symbol?(ast)
	ast.instance_of? String
end

def is_list?(ast)
	ast.instance_of? Array
end

def is_boolean?(ast)
	ast.instance_of? Bool
end

def is_integer?(ast)
	ast.instance_of? Int
end

def is_closure?(ast)
	ast.instance_of? Closure
end

def is_atom?(ast)
	return is_symbol? || is_integer? || is_boolean? || is_closure
end	