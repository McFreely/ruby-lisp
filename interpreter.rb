require_relative 'evaluator'
require_relative 'parser'
require_relative 'types'

# require 'pry'

def interpret(source, env = nil)

	if env.nil?
	# env = env || Environment.new
		env = Environment.new
	end
	unparse(evaluate(parse(source), env))
end

def interpret_file(filename, env = nil)
	if env.nil?
		env = Environment.new
	end
	sourcefile = File.open(filename, "r")
	source = sourcefile.readlines.join(" ")
	asts = parse_multiple(source)
	results = [asts.map {|ast| evaluate(ast, env)}]
	unparse(results[-1])
end