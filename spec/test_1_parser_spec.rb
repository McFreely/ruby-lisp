require 'spec_helper'
require './parser'

describe "Parsing" do
	it "should parse a single symbol" do
		# Symbols are represented by text strings.
		# Parsing a single atom should result in an AST consisting of only that symbol

		expect(parse("foo")).to eq("foo")
	end

	it "should parse a single boolean" do
		# Booleans are the special symbols #t and #f
		# In the ASTs they are represented by Ruby true and false, respectively

		expect(parse('#t')).to eq(true)
		expect(parse('#f')).to eq(false)
	end

	it "should parse a single integer" do
		# Integers are represented in the ASTs as Ruby ints

		expect(parse('42')).to eq(42)
		expect(parse('1337')).to eq(1337)
	end

	it "should parse a list of only symbols" do
		# A list is reoresented by a number of elements surrounded by parens
		# Ruby arrays are used to represent  lists as ASTs
		#
		# Tip: the useful helper function 'find_matching_paren' is already provided
		# in 'parser.rb'

		list = %w(foo bar list)
		empty_list = []
		expect(parse('(foo bar baz)')).to eq(list)
		expect(parse('()')).to eq(empty_list)
	end

	it "should parse a list of mixed types" do
		# When parsing lists, make sure each of the sub-expressions are also parsed properly

		expect(parse('(foo #t 123)')).to eq(%w(foo true 123))
	end

	it "should parse a snested list" do
		program = '(foo (bar ((#t)) x) (baz y))'
		ast = ['foo',
		       ['bar', [[true]], 'x'],
		       ['baz', 'y']]
		expect(parse(program)).to eq(ast)
	end

	it "should raise an execption if any paren is missing" do
		program = "(foo (bar x y)"

		expect(parse(program)).to raise_error(LispError, "Incomplete expression")
	end

	it "should raise an execption if there is too much parens" do
		# The parse function expects to receive onlyu one single expression
		# Anything more than this, should result in the proper exception
		program = "(foo (bar x y)))"

		expect(parse(program)).to raise_error(LispError, "Expected EOF")
	end

	it "should remove excess whitespace" do
		program = "(program   with      much   whitespace  )      "
		ast = %w{program with much whitespace}

		expect(parse(program)).to eq(ast)
	end

	it "should strip comments" do
		program = " ;the first line is a comment
					     (define variable
					     		;another comment
					     		if #t
					     			 42 ;inline comment!
					     			 (something else)))"

		ast = ["define", "variable",
										 ["if", true,
										 	 42,
										 	 ["something", "else"]]]

	  expect(parse(program)).to eq(ast)
	end

	it "should be able to parse a large input" do
		program = " (define fact
									;; Factorial function
									(lambda (n)
										  (if (<= n 1)
										  	  1 ;Factorial of 0 is 1, and we deny
										  	    ;the existence of negative numbers
										  	  (* n (fact (- n 1))))))"
					    
    ast = ['define', 'fact',
                    ['lambda', ['n'],
                     ['if', ['<=', 'n', '1'],
                      1,
                      ['*', 'n', ["fact", ["-", "n", 1]]]]]]

    expect(parse(program)).to eq(ast)
  end


  #
  # The following tests checks that quote expansion works properly
  # 

  it "should extend the shorthand quote syntax" do
  	# Quoting is a shorthand syntax for calling the quote form
  	# Examples:
  	#
  	# 		`foo       -> (quote foo)
  	#     `(foo bar) -> (quote (foo bar))
  	program = "(foo `nil)"
  	ast = ["foo", ["quote", "nil"]]

  	expect(parse(program)).to eq(ast)
  end

  it 'should expand nested quotes' do
  	program = "````foo"
  	ast = ["quote", ["quote", ["quote", ["quote", "foo"]]]]

  	expect(parse(program)).to eq(ast)
  end
end


