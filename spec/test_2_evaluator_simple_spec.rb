# -*- coding: utf-8 -*-
require 'spec_helper'
require './code/evaluator'
require './code/types'

describe 'Simple Evaluation' do
  environment = Environment.new

  it "should evaluate booleans to themselves" do
    expect(evaluate(true, environment)).to eq(true)
    expect(evaluate(false, environment)).to eq(false)
  end

  it 'should evaluate integers to themselves' do
    expect(evaluate(42, environment)).to eq(42)
  end

  it 'should evaluate quote' do
    # When a quote form is called, the argument should be returned without
    # being evaluated
    #
    # (quote foo) -> foo
    expect(evaluate(["quote","foo"], environment)).to eq("foo")
    expect(evaluate(["quote", [1, 2, false]], environment)).to eq([1, 2, false])
  end

  it 'should evaluate atoms' do
    # The atom form is used to determine whether an expression is
    # an atom
    #
    # Atoms are expressions that are not list, i.e. integers, booleans
    # or symbols.
    # Remember that the argument to 'atom' must be evaluated before the check is done.

    expect(evaluate(["atom", true], environment)).to eq(true)
    expect(evaluate(["atom", false], environment)).to eq(true)
    expect(evaluate(["atom", 42], environment)).to eq(true)
    expect(evaluate(["atom", ["quote", "foo"]], environment)).to eq(true)
    expect(evaluate(["atom", ["quote", [1, 2]]], environment)).to eq(false)
  end

  it "should evaluate eq function" do
    # The 'eq' form is used to check whether two expressions are
    # the same atom
    expect(evaluate(["eq", 1, 1], environment)).to eq(true)
    expect(evaluate(["eq", 1, 2], environment)).to eq(false)

    ast1 = ["eq", ["quote", "foo"], ["quote", "foo"]]
    expect(evaluate(ast1, environment)).to eq(true)

    ast2 = ["eq", ["quote", "foo"], ["quote", "bar"]]
    expect(evaluate(ast2, environment)).to eq(false)

    ast3 = ["eq", ["quote", [1,2,3]], ["quote", [1,2,3]]]
    expect(evaluate(ast3, environment)).to eq(false)
  end

  it "should evaluate basic math operations" do
    # To be able to do anything useful, we need some basic math
    # operators
    #
    # Since we only operate with integers, '/' must represent integer division.
    # 'mod' is modulo operator

    expect(evaluate(["+", 2, 2], environment)).to eq(4)
    expect(evaluate(["-", 2, 1], environment)).to eq(1)
    expect(evaluate(["*", 2, 3], environment)).to eq(6)
    expect(evaluate(["/", 6, 2], environment)).to eq(3)
    expect(evaluate(["/", 7, 2], environment)).to eq(3)
    expect(evaluate(["mod", 7, 2], environment)).to eq(1)
    expect(evaluate([">", 7, 2], environment)).to eq(true)
    expect(evaluate([">", 2, 7], environment)).to eq(false)
    expect(evaluate([">", 7, 7], environment)).to eq(false)
    # Might need more tests to cover other operators: '<', '<=', '=>'
  end

  it 'should evaluate math operations only on numbers' do
    expect{evaluate(["+", 1 ,["quote", "foo"]], environment)}.to raise_error(LispError)
    expect{evaluate(["-", 1 ,["quote", "foo"]], environment)}.to raise_error(LispError)
    expect{evaluate(["*", 1 ,["quote", "foo"]], environment)}.to raise_error(LispError)
    expect{evaluate(["+", 1 ,["quote", "foo"]], environment)}.to raise_error(LispError)
    expect{evaluate(["mod", 1 ,["quote", "foo"]], environment)}.to raise_error(LispError)
  end
end
