# This is the parser module, with the 'parse' function
# which you'll implement as part 1 of the workshop.
# Its job is to convert strings into data structures that
# the evaluator can understand

def parse(source)
	# Parse string representation of one *single*
	# expression into the corresponding Abstract Syntax Tree

	raise NotImplementedError, "Do It Yourself"
end

# Below are a few useful utility functions. These should
# come in handy when implementing 'parse'. We don't
# want to spend the day implementing parenthesis counting
# after all.

def remove_comments(source)
	# Remove from a string anything in between a ; and a linebreak
	source.sub(/;.*\n/, "\n")
end

def find_matching_paren(source, start = 0)
	# Given a string and the index of an opening paren,
	# determines the index of the matching closing paren.
	raise "The program is not valid Lisp" unless source[start] == "("
	pos = start
	open_parens = 1
	while open_parens > 0 do
		pos += 1
		if source.length == pos 
			raise ArgumentError, 'Incomplete Expression'
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
	source = source.strip
	exps = []
	while rest
		exp, rest = first_expression(rest)
		exps.app(exp)
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
		return source[0..last + 1], source[last + 1..-1]
	else
		match = /^[^\s)']+/.match(source) # some renaming to do here
		ending = match.end(0)
		atom = source[0..ending]
		return atom, source[ending..-1]
	end
end


# The functions below, 'parse_multiple' and 'unparse' are
# implemented in order for the REPL to work. Don't worry
# about them when implementing the language.

def parse_multiple(source)
	# Create a list of ASTs from program source constituting
	# multiple expressions.
	source = remove_comments(source)
	split_exps(source).each do |exp|
		parse(exp)
	end
end

def unparse(ast)
	# Turn an AST back into lisp program source
	if is_boolean(ast)
		ast ? '#t' : '#f'
	elsif is_list(ast)
		if ast.length > 0 && ast[0] == "quote"
			return "'%s" % [unparse(ast[1])]
		else
			return "(%s)" % [ast.each {|x| x.join(" ")}]
		end
	else
		ast.to_s
	end 
end

