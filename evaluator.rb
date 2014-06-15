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
    env.set(ast[1], evaluate(ast[2],env))
    return ast[1]
end