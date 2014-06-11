require 'spec_helper'

require './types'
require './evaluator'
require './parser'

# Before we go on to evaluating programs using variables, we
# need to implement an environment to store them in.
#
# It is time to fill in the blanks in the 'Environment' class
# located in 'types.rb'

describe 'Environment' do
	it 'should store variables and provide lookup' do
		env = Environment({"var" => 42})
		expect(env.lookup("var")).to eq(42)
	end

	it 'should raise an expection when loooking up an undefined symbol' do
		# The error message should contain the relevant symbol, and inform
		# that it has not been defined.
		empty_env = Environment.new
		expect(empty_env.lookup("my-missing-var")).to raise_error(LispError, "my-missing-var")
	end

	it 'should lookup from inner env' do
		# The 'extend' function return a new environment extended
		# with more bindings

		env = Environment({"foo" => 42})
		env = env.extend({"bar" => true})
		expect(env.lookup("foo")).to eq(42)
		expect(env.lookup("bar")).to eq(true)
	end

	it 'should lookup a deeply nested var' do
		# Extending overwrites old bindings to the same variable name

		env = Environment({"a" => 1}).extend({"b" => 2}).extend({"c" => 3}).extend({"foo" => 100})
		expect(env.lookup("foo")).to eq(100)
	end

	it 'should create a new env when extend is called' do
		# The 'extend' method should create a new env, leaving
		# the old one unchanged.
		env = Environment({"foo" => 1})
		extended = env.extend({"foo" => 2})

		expect(env.lookup("foo")).to eq(1)
		expect(extended.lookup("foo")).to eq(2)
	end

	it 'should update the environment with set' do
		env = Environment.new
		env.set("foo" => 2)
		expect(env.lookup("foo")).to eq(2)
	end

	it 'should be illegal to redefine variables' do
		# Variables can only be defined once.
		#
		# Setting a variable in a environment where it is already defined
		# should result in an appropriate error
		env = Environment({"foo" => 1})
		expect(env.set("foo", 2)).to raise_error(LispError, "Variable already defined")		
	end
end


# With the 'Environment' working, it's time to implement evaluation
# of expressions with variables

describe 'Variable Evaluation' do
	it 'should evaluate symbols' do
		# Symbols (other than #t and #f) are trated as variable references.
		# 
		# When evaluating a symbol, the corresponding value should be looked up in
		# the environment.
		env = Environment({"foo" => 42})
		expect(evaluate("foo", env)).to eq(42)
	end

	it 'should raise an exception when referencing undefined var' do
		# This test should already pass if you implemented the environment correctly.
		expect(evaluate("my_var", Environment.new)).to raise_error(LispError, "my_var")
	end

	it 'should evaluate define statement' do
		# The 'define' form is used to define new binding in the environment.
		# A 'define' call should result in a change in the environment. What you
		# return from evaluating the defineition is not important (although)
		# it affects what is printed in the REPL).
		env = Environment.new
		evaluate(parse("(define x 1000)"), env)
		expect(env.lookup("x")).to eq(1000)
	end

	it 'should raise an error when define is called with wrong number of args' do
		env = Environment.new
		expect(evaluate(parse("(define x)")), env).to raise_error(LispError, "Wrong number of arguments")
		expect(evaluate(parse("(define x 1 2)"), env)).to raise_error(LispError, "Wrong number of arguments")
	end

	it 'should require the first argument to be a symbol' do
		env = Environment.new
		expect(evaluate(parse("(define #t 42)"), env)).to raise_error(LispError, "non-symbol")
	end

	it 'should be able to lookup variable after define' do
		# This test should already be passing when the above ones are passing.
		env = Environment.new
		evaluate(parse("(define foo (+ 2 2))"), env)
		expect(evaluate("foo", env)).to eq(4)
	end
end
