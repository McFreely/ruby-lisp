require_relative 'types'

# This module contains a few simple helper functions
# for checking the type os as_trees

def is_symbol?(as_tree)
	as_tree.instance_of? String
end

def is_list?(as_tree)
	as_tree.instance_of? Array
end

def is_boolean?(as_tree)
	as_tree.instance_of?(TrueClass) || as_tree.instance_of?(FalseClass)
end

def is_integer?(as_tree)
	as_tree.instance_of? Int
end

def is_closure?(as_tree)
	as_tree.instance_of? Closure
end

def is_atom?(as_tree)
	return is_symbol? || is_integer? || is_boolean? || is_closure
end	