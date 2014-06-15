require_relative 'parser'

def assert_expression_length(ast, length)
	if ast.length > length
		raise LispError, "Malformed %s, too many arguments: %s" % ast[0], unparse(ast)
	elsif ast.length < length
		raise LispError, "Malformed %s, too few arguments: %s" % ast[0], unparse(ast)
	end
end

def assert_valid_definition(d)
	if d.length != 2
		raise LispError, "Wrong number of arguments for variable definition: %s" % d
	elsif !d[0].instance_of String
		raise LispError, "Attempted to define non-symbol as variable: %s" % d
	end
end

def assert_boolean(p, exp = nil)
	if ! is_boolean(p)
		msg = "Boolean required, got '%s'. " % unparse(p)
		unless exp.is_nil
			msg += "Offending expression: %s" % unparse(exp)
		end
		raise LispError, msg
	end
end
