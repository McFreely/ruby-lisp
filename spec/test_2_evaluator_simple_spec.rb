# -*- coding: utf-8 -*-
require 'minitest/autorun'
require './code/evaluator'
require './code/types'

describe 'Simple Evaluation' do
  environment = Environment.new

  it "should evaluate booleans to themselves" do
    assert_equal evaluate(true, environment), true
    assert_equal evaluate(false, environment), false
  end

  it 'should evaluate integers to themselves' do
    assert_equal evaluate(42, environment), 42
  end

  it 'should evaluate quote' do
    # When a quote form is called, the argument should be returned without
    # being evaluated
    #
    # (quote foo) -> foo
    assert_equal evaluate(["quote","foo"], environment), "foo"
    assert_equal evaluate(["quote", [1, 2, false]], environment)
  end

  it 'should evaluate atoms' do
    # The atom form is used to determine whether an expression is
    # an atom
    #
    # Atoms are expressions that are not list, i.e. integers, booleans
    # or symbols.
    # Remember that the argument to 'atom' must be evaluated before the check is done.

    assert_equal evaluate(["atom", true], environment), true
    assert_equal evaluate(["atom", false], environment), true
    assert_equal evaluate(["atom", 42], environment), true
    assert_equal evaluate(["atom", ["quote", "foo"]], environment), true
    assert_equal evaluate(["atom", ["quote", [1, 2]]], environment), false
  end

  it "should evaluate eq function" do
    # The 'eq' form is used to check whether two expressions are
    # the same atom
    assert_equal evaluate(["eq", 1, 1], environment), true
    assert_equal evaluate(["eq", 1, 2], environment), false

    ast1 = ["eq", ["quote", "foo"], ["quote", "foo"]]
    assert_equal evaluate(ast1, environment), true

    ast2 = ["eq", ["quote", "foo"], ["quote", "bar"]]
    assert_equal evaluate(ast2, environment), false

    ast3 = ["eq", ["quote", [1,2,3]], ["quote", [1,2,3]]]
    assert_equal evaluate(ast3, environment), false
  end

  it "should evaluate basic math operations" do
    # To be able to do anything useful, we need some basic math
    # operators
    #
    # Since we only operate with integers, '/' must represent integer division.
    # 'mod' is modulo operator

    assert_equal evaluate(["+", 2, 2], environment), 4
    assert_equal evaluate(["-", 2, 1], environment), 1
    assert_equal evaluate(["*", 2, 3], environment), 6
    assert_equal evaluate(["/", 6, 2], environment), 3
    assert_equal evaluate(["/", 7, 2], environment), 3
    assert_equal evaluate(["mod", 7, 2], environment), 1
    assert_equal evaluate([">", 7, 2], environment), true
    assert_equal evaluate([">", 2, 7], environment), false
    assert_equal evaluate([">", 7, 7], environment), false
    # Might need more tests to cover other operators: '<', '<=', '=>'
  end

  it 'should evaluate math operations only on numbers' do
    assert_raises(LispError) {evaluate(["+", 1 ,["quote", "foo"]], environment)}
    assert_raises(LispError) {evaluate(["-", 1 ,["quote", "foo"]], environment)}
    assert_raises(LispError) {evaluate(["*", 1 ,["quote", "foo"]], environment)}
    assert_raises(LispError) {evaluate(["+", 1 ,["quote", "foo"]], environment)}
    assert_raises(LispError) {evaluate(["mod", 1 ,["quote", "foo"]], environment)}
  end
end
