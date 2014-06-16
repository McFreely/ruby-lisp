require 'spec_helper'

require './parser'
require './types'
require './ast'
# This file contains a few test for the code provided for part 1
# All tests here should already pass, and should be of no concern to
# you as a workshop attendee.

describe 'find_parens' do
	it 'should find matching parens' do
		source = "(foo (bar) '(this ((is)) quoted))"
		expect(find_matching_paren(source, 0)).to eq(32)
		expect(find_matching_paren(source, 5)).to eq(9)
	end

	it 'should find matching empty parens' do
		expect(find_matching_paren("()", 0)).to eq(1)
	end

	it 'should throw an expection on bad initial position' do
		expect{find_matching_paren("string without paren", 4)}.to raise_error(LispError)
	end

	it 'should throw an expection when there is no closing paren' do		
		expect{find_matching_paren("string (without matching paren", 7)}.to raise_error(LispError)
	end
end

describe 'unparse' do
	it 'works on atoms' do
		expect(unparse(123)).to eq("123")
		expect(unparse(true)).to eq("#t")
		expect(unparse(false)).to eq("#f")
		expect(unparse("foo")).to eq("foo")
	end

	it 'works on lists' do
		expect(unparse([["foo", "bar"], "baz"])).to eq("((foo bar) baz)")
	end

	it 'works on quotes' do
		tree = unparse(["quote", ["quote", ["foo", ["quote", "bar"], ["quote", [1,2]]]]])
		expect(tree).to eq("''(foo 'bar '(1 2))")
	end

	it 'works on integers' do
		expect(unparse(1)).to eq("1")
		expect(unparse(1337)).to eq("1337")
		expect(unparse(-42)).to eq("-42")
	end

	it 'works on symbols' do
		expect(unparse("+")).to eq("+")
		expect(unparse("foo")).to eq("foo")
		expect(unparse("lambda")).to eq("lambda")
	end

	it 'works on other lists' do
		expect(unparse([1,2,3])).to eq("(1 2 3)")
		expect(unparse(["if", true, 42, false])).to eq("(if #t 42 #f)")
	end

	it 'works on other quotes' do
		expect(unparse(["quote", "foo"])).to eq("'foo")
		expect(unparse(["quote", [1,2,3]])).to eq("'(1 2 3)")
	end

	it 'works on empty list' do
		expect(unparse([])).to eq("()")
	end
end
