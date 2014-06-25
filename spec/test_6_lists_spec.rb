require 'spec_helper'

require './code/evaluator'
require './code/parser'
require './code/types'

describe 'List' do
	it 'can be created by quoting' do
		# We have already implemented 'quote' so this test should already be passing
		# The reason we need to use 'quote' here is that ohterwise the
		# the expression would be seen as a call to the first element -- '1' in that
		# case, which obviously isn't even a function.
		env = Environment.new
		program = parse("'(1 2 3 #t)")
		expect(evaluate(program, env)).to eq(parse("(1 2 3 #t)"))
	end	

	it 'can be created with cons' do
		# The 'cons' function prepends an element to the front of a list.
		result = evaluate(parse("(cons 0 '(1 2 3))"), Environment.new)
		expect(result).to eq(parse("(0 1 2 3)"))
	end

	it 'can be created by consing lists' do
		# 'cons' need to evaluate it's arguments.
		#
		# Like all the other special forms and functions in our language, 'cons' is
		# call-by-value. This means that the arguments must be evaluated before we 
		# create the list with their values.
		result = evaluate(parse("(cons 3 (cons (- 4 2) (cons 1 '())))"), Environment.new)
		expect(result).to eq(parse("(3 2 1)"))
	end 

	it 'has a method to extract its first element' do
		# 'head' extracts the first element of a list
		result = evaluate(parse("(head '(1 2 3 4 5))"), Environment.new)
		expect(result).to eq(1)
	end

	it 'cannot extract first element if empty' do
		expect{evaluate(parse("(head (quote ()))"), Environment.new)}.to raise_error(LispError)
	end

	it 'has a method to return its tail' do
		# The tail is the list retained after removing the first element.
		expect(evaluate(parse("(tail '(1 2 3))"), Environment.new)).to eq([2, 3])
	end

	it 'has a method to check emptyness' do
		expect(evaluate(parse("(empty '(1 2 3))"), Environment.new)).to eq(false)
		expect(evaluate(parse("(empty '(1))"), Environment.new)).to eq(false)

		expect(evaluate(parse("(empty '())"), Environment.new)).to eq(true)
		expect(evaluate(parse("(empty (tail '(1)))"), Environment.new)).to eq(true)
	end
end

