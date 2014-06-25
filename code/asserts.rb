require_relative 'parser'

def assert_expression_length(ast, length)
	if ast.length > length
		raise LispError
	elsif ast.length < length
		raise LispError
	end
end

def assert_valid_definition(d)
	if d.length != 2
		raise LispError, "Wrong number of arguments"
	elsif !d[0].kind_of? String
		raise LispError, "Non-symbol"
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
