# -*- coding: utf-8 -*-
require_relative 'types'
require_relative 'ast'
require_relative 'asserts'
require_relative 'parser'


# This is the Evaluator module. The 'evaluate' function is the heart
# of your language, and the focus for most of parts 2 through 6
#
# A score of useful functions is provided for you, as per the above imports,

# making your work a bit easier. (We're supposed to get through this thing in a day,
# after all.)

# require 'pry'

def evaluate(ast, env)
  return env.lookup(ast) if is_symbol?(ast)
  
  return ast if is_atom?(ast)
  
  if is_list?(ast)
  	
  	if ast[0] == "quote"
  		eval_quote(ast, env)
  	
  	elsif ast[0] == "atom"
  		eval_atom(ast, env)
  	
  	elsif ast[0] == "eq"
  		eval_eq(ast, env)
  	
  	elsif ["+", "-", "*", "/", "mod", ">"].include? ast[0]
  		eval_math(ast, env)
  	
  	elsif ast[0] == "if"
  		eval_if(ast, env)
  	
  	elsif ast[0] == "define"
  		eval_define(ast, env)
  	
  	elsif ast[0] == "lambda"
  		eval_lambda(ast, env)

  	elsif ast[0] == "cons"
  		eval_cons(ast, env)
  	elsif ast[0] == "head"
  		ast[1][1].empty? ? raise(LispError) : ast[1][1][0]
  	elsif ast[0] == "tail"
  		ast[1][1][1..-1]
  	elsif ast[0] == "empty"
  		evaluate(ast[1],env).empty?

  	elsif is_closure?(ast[0])
  		apply(ast, env)
    
    elsif is_symbol?(ast[0]) || is_list?(ast[0])
  	 	closure = evaluate(ast[0], env)
  	 	new_ast = [closure] + ast[1..-1]
  	    evaluate(new_ast, env)
  
  	else
  		raise LispError, 'not a function'
  
  	end
  end
end

def eval_quote(ast, env)
	assert_expression_length(ast, 2)
	ast[1]
end

def eval_atom(ast, env)
	arg = evaluate(ast[1], env)
	is_atom?(arg)
end

def eval_eq(ast, env)
	assert_expression_length(ast, 3)
	v1, v2 = evaluate(ast[1], env), evaluate(ast[2], env)
	v1 == v2 && is_atom?(v1) ? true : false
end

def eval_math(ast, env)
	ops = {
		"+" => ->(a,b){ a + b },
		"-" => ->(a,b){ a - b },
		"*" => ->(a,b){ a * b },
		"/" => ->(a,b){ a / b },
		"mod" => ->(a,b){ a % b },
		">" => ->(a,b){ a > b },
	}
	op = ast[0]
	a = evaluate(ast[1], env)
	b = evaluate(ast[2], env)
	if is_integer?(a) && is_integer?(b)
		ops[op].call(a,b)
	else
		raise LispError
	end
end

def eval_if(ast, env)
	assert_expression_length(ast, 4)
	evaluate(ast[1], env) ? evaluate(ast[2], env) : evaluate(ast[3], env)
end

def eval_define(ast, env)
	assert_valid_definition(ast[1..-1])
    symbol = ast[1]
    value = evaluate(ast[2], env)
    env.set(symbol, value)
    symbol
end

def eval_lambda(ast, env)
	raise LispError, "Wrong number of Arguments" unless ast.length == 3
	params = ast[1]
	raise LispError, "Lamdba parameter as non-list" unless is_list?(params)
	body = ast[2]
	Closure.new(env, params, body)
end

def eval_cons(ast, env)
	assert_expression_length(ast, 3)
	car = evaluate(ast[1], env)
	cdr = evaluate(ast[2], env)
	cdr.insert(0, car)
end

def apply(ast, env)
	closure = ast[0]
	args = ast[1..-1]
	if args.length != closure.params.length
		msg = "wrong number of arguments, expected #{closure.params.length} got #{args.length}"
		raise LispError, msg
	end
	args = args.collect do |a|
		evaluate(a, env)
	end
	bindings = Hash[closure.params.zip(args)]
	new_env = closure.env.extend(bindings)
	evaluate(closure.body, new_env)
end