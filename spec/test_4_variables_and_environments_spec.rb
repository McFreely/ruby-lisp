require 'minitest/autorun'

require './code/types'
require './code/evaluator'
require './code/parser'

# Before we go on to evaluating programs using variables, we
# need to implement an environment to store them in.
#
# It is time to fill in the blanks in the 'Environment' class
# located in 'types.rb'

describe 'Environment' do
	it 'should store variables and provide lookup' do
		env = Environment.new({"var" => 42})
		assert_equal env.lookup("var"), 42
	end

	it 'should raise an expection when loooking up an undefined symbol' do
		# The error message should contain the relevant symbol, and inform
		# that it has not been defined.
		empty_env = Environment.new
		assert_raises(LispError, "my-missing-var") {empty_env.lookup("my-missing-var")}
	end

	it 'should lookup from inner env' do
		# The 'extend' function return a new environment extended
		# with more bindings

		env = Environment.new({"foo" => 42})
		env = env.extend({"bar" => true})
		assert_equal env.lookup("foo"), 42
		assert_equal env.lookup("bar"), true
	end

	it 'should lookup a deeply nested var' do
		# Extending overwrites old bindings to the same variable name
		# pending "extend doesn't chain correctly but the test should pass otherwise"
		env = Environment.new({"a" => 1}).extend({"b" => 2}).extend({"c" => 3}).extend({"foo" => 100})
		assert_equal env.lookup("foo"), 100
	end

	it 'should create a new env when extend is called' do
		# The 'extend' method should create a new env, leaving
		# the old one unchanged.
		env = Environment.new({"foo" => 1})
		extended = env.extend({"foo" => 2})

		assert_equal env.lookup("foo"), 1
		assert_equal extended.lookup("foo"), 2
	end

	it 'should update the environment with set' do
		env = Environment.new
		env.set("foo", 2)
		assert_equal env.lookup("foo"), 2
	end

	it 'should be illegal to redefine variables' do
		# Variables can only be defined once.
		#
		# Setting a variable in a environment where it is already defined
		# should result in an appropriate error
		env = Environment.new({"foo" => 1})
		assert_raises(LispError, "Variable already defined") {env.set("foo", 2)}
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
		env = Environment.new({"foo" => 42})
		assert_equal evaluate("foo", env), 42
	end

	it 'should raise an exception when referencing undefined var' do
		# This test should already pass if you implemented the environment correctly.
		assert_raises(LispError, "my_var") {evaluate("my_var", Environment.new)}
	end

	it 'should evaluate define statement' do
		# The 'define' form is used to define new binding in the environment.
		# A 'define' call should result in a change in the environment. What you
		# return from evaluating the definition is not important (although)
		# it affects what is printed in the REPL).
		env = Environment.new
		evaluate(parse("(define x 1000)"), env)
		assert_equal env.lookup("x"), 1000
	end

	it 'should raise an error when define is called with wrong number of args' do
		env = Environment.new
		assert_raises(LispError, "Wrong number of arguments") {evaluate(parse("(define x)"), env)}
		assert_raises(LispError, "Wrong number of arguments") {evaluate(parse("(define x 1 2)"), env)}
	end

	it 'should require the first argument to be a symbol' do
		env = Environment.new
		assert_raises(LispError, "Non-symbol") {evaluate(parse("(define #t 42)"), env)}
	end

	it 'should be able to lookup variable after define' do
		# This test should already be passing when the above ones are passing.
		env = Environment.new
		evaluate(parse("(define foo (+ 2 2))"), env)
		assert_equal evaluate("foo", env), 4
	end
end
