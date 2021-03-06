# This is the parser module, with the 'parse' function
# which you'll implement as part 1 of the workshop.
# Its job is to convert strings into data structures that
# the evaluator can understand

require_relative 'ast'
require_relative 'types'

def parse(source)
	# Parse string representation of one *single*
	# expression into the corresponding Abstract Syntax Tree
	
	# to do in order like Jiw Weirlich
	# From simple to complex, following the specs
	raise NotImplementedError, "Do it Yourself"
end

# Below are a few useful utility functions. These should
# come in handy when implementing 'parse'. We don't
# want to spend the day implementing parenthesis counting
# after all.

def remove_comments(source)
	# Remove from a string anything in between a ; and a linebreak
	source = source.gsub(/;.*/, " ")
	source = source.delete("\n\t")
	source
end

def find_matching_paren(source, start = 0)
	# Given a string and the index of an opening paren,
	# determines the index of the matching closing paren.
	raise LispError, "Invalid Lisp" unless source[start] == "("	
	pos = start
	open_parens = 1
	until open_parens <= 0 do
		pos += 1
		if source.length == pos 
			raise LispError, "Incomplete expression: %s" % source[start..-1]
		elsif source[pos] == "("
			open_parens += 1
		elsif source[pos] == ")"
			open_parens -= 1
		end
	end
	pos
end

def split_exps(source)
	# Splits a source string into subexpressions
	# that can be parsed individually.
	rest = source.strip
	exps = []
	until rest.empty?
		exp, rest = first_expression(rest)
		exps << exp
	end
	exps
end

def first_expression(source)
	# Split string into (exp, rest) where exp is the
	# first expression in the string and rest is the 
	# rest of the string after this expression.
	source = source.strip
	if source[0] == "'"
		exp, rest = first_expression(source[1..-1])
		return source[0] + exp, rest
	elsif source[0] == "("
		last = find_matching_paren(source)
		return source[0..last], source[last+1..-1]
	else
		pat = /^[^\s)']+/ 
		m = pat.match(source)
		unless m.nil? 
		    ending = m.end(0)
			atom = source[0..ending-1]
			return atom, source[ending..-1]
		end
	end
end


# The functions below, 'parse_multiple' and 'unparse' are
# implemented in order for the REPL to work. Don't worry
# about them when implementing the language.

def parse_multiple(source)
	# Create a list of ASTs from program source constituting
	# multiple expressions.
	source = remove_comments(source)
	split_exps(source).collect do |exp|
		parse(exp)
	end
end

def unparse(as_tree)
	# Turn an AST back into lisp program source
	if is_boolean?(as_tree)
		as_tree = as_tree ? '#t' : '#f'
	elsif is_list?(as_tree)
		if as_tree.length > 0 && as_tree[0] == "quote"
			return "'%s" % [unparse(as_tree[1])]
		else
		    
			return "(%s)" % [as_tree.map {|x| unparse(x)}.join(" ")]
		end
	else
		as_tree.to_s
	end 
end

class String
	# Helper for the class function
	def is_numeric?
		Float(self) != nil rescue false
	end
end