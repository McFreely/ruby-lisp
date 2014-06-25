require_relative 'types'

# This module contains a few simple helper functions
# for checking the type of as_trees

def is_symbol?(as_tree)
	as_tree.kind_of? String
end

def is_list?(as_tree)
	as_tree.kind_of? Array
end

def is_boolean?(as_tree)
	as_tree.kind_of?(TrueClass) || as_tree.kind_of?(FalseClass)
end

def is_integer?(as_tree)
	as_tree.kind_of? Integer
end

def is_closure?(as_tree)
	as_tree.kind_of? Closure
end

def is_atom?(as_tree)
	return is_symbol?(as_tree) || is_integer?(as_tree) || is_boolean?(as_tree) || is_closure?(as_tree)
end	