require 'minitest/autorun'

require './code/parser'
require './code/types'
require './code/ast'
# This file contains a few test for the code provided for part 1
# All tests here should already pass, and should be of no concern to
# you as a workshop attendee.

describe 'find_parens' do
	it 'should find matching parens' do
		source = "(foo (bar) '(this ((is)) quoted))"
		assert_equal find_matching_paren(source, 0), 32
		assert_equal find_matching_paren(source, 5), 9
	end

	it 'should find matching empty parens' do
		assert_equal find_matching_paren("()", 0), 1
	end

	it 'should throw an expection on bad initial position' do
		assert_raises(LispError, "Invalid Lisp") {find_matching_paren("string without paren", 4)}
	end

	it 'should throw an expection when there is no closing paren' do		
		assert_raises(LispError, 'Incomplete expression') {find_matching_paren("string (without matching paren", 7)}
	end
end

describe 'unparse' do
	it 'works on atoms' do
		assert_equal unparse(123), "123"
		assert_equal unparse(true), "#t"
		assert_equal unparse(false), "#f"
		assert_equal unparse("foo"), "foo"
	end

	it 'works on lists' do
		assert_equal unparse([["foo", "bar"], "baz"]), "((foo bar) baz)"
	end

	it 'works on quotes' do
		tree = unparse(["quote", ["quote", ["foo", ["quote", "bar"], ["quote", [1,2]]]]])
		assert_equal tree, "''(foo 'bar '(1 2))"
	end

	it 'works on integers' do
		assert_equal unparse(1), "1"
		assert_equal unparse(1337), "1337"
		assert_equal unparse(-42), "-42"
	end

	it 'works on symbols' do
		assert_equal unparse("+"), "+"
		assert_equal unparse("foo"), "foo"
		assert_equal unparse("lambda"), "lambda"
	end

	it 'works on other lists' do
		assert_equal unparse([1,2,3]), "(1 2 3)"
		assert_equal unparse(["if", true, 42, false]), "(if #t 42 #f)"
	end

	it 'works on other quotes' do
		assert_equal unparse(["quote", "foo"]), "'foo"
		assert_equal unparse(["quote", [1,2,3]]), "'(1 2 3)"
	end

	it 'works on empty list' do
		assert_equal unparse([]), "()"
	end
end
