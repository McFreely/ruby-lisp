require 'spec_helper'

require './ast'
require './evaluator'
require './parser'
require './types'

# This part is all about defining and using functions.
#
# We'll start by implementing the 'lambda' form which is used
# to create function closures.

describe 'Closure' do
	it 'should evaluate to a closure' do
		ast = ["lambda", [], 42]
		closure = evaluate(ast, Environment.new)
		expect(closure).to be_a Closure
	end

	it 'should keep a copy of the env where it was defined' do
		# Once we start calling functions later, we'll need access to the environment
		# from when the function was created in order to resolve all free variables.
		env = Environment.new({"foo" => 1, "bar" => 2})
		ast = ["lambda", [], 42]
		closure = evaluate(ast, env)
		expect(closure.env).to eq(env)
	end

	it 'should contain the parameter list and function body' do
		closure = evaluate(parse("(lambda (x y) (+ x y))"), Environment.new)

		expect(closure.params).to eq(["x", "y"])
		expect(closure.body).to eq(["+", "x", "y"])		
	end

	it 'parameters should be a list' do
		closure = evaluate(parse("(lambda (x y) (+ x y))"), Environment.new)
		
		expect(is_list?(closure.params)).to eq(true)
		expect{evaluate(parse('(lambda not-a-list (body of fn))'), Environment.new)}.to raise_error(LispError, "Lamdba parameter as non-list")
	end

	it 'should expect exactly two arguments' do
		expect{evaluate(parse("(lambda (foo) (bar) (baz))"), Environment.new)}.to raise_error(LispError, "Wrong number of Arguments")
	end

	it "should define lambda with error in body" do
		# The function body should not be evaluated when the lambda is defined
		#
		# The call to 'lambda' should return a function closure holding, among
		# other things, the function body. The body should not be evaluated before
		# the function is called.
		env = Environment.new
		ast = parse("(lambda (x y)
						(function body ((that) would never) work))")
		expect(evaluate(ast, env)).to be_a Closure
	end
end


# Now that we have the 'lambda' form implemented, let's see if we can call some functions.
#
# When evaluating ASTs which are lists, if the first element isn't one of the special forms
# we have been working with so far, it is a function call. The first element of the list is
# the function, and the rest of the elements are arguments.

describe 'Functions calls' do
	it 'should evaluate call to closure' do
		# The first case we'll handle is when the AST is a list with an actual closure
		# as the first element.
		#
		# In this first test, we'll start with a closure with no arguments and no free
		# variables. All we need to do is to evaluate and return the function body.
		closure = evaluate(parse("(lambda () (+ 1 2))"), Environment.new)
		ast = [closure]
		result = evaluate(ast, Environment.new)
		expect(result).to eq(3)
	end 

	it 'should evaluate call to closure with arguments' do
		# The function body must be evaluated in a environment where the parameters are bound.
		#
		# Create an env where the function parameters (which are stored in the closure) are bound
		# to the actual argument values in the function call. Use this env when evaluating
		# the function body.

		env = Environment.new
		closure = evaluate(parse("(lambda (a b) (+ a b))"), env)
		ast = [closure, 4, 5]

		expect(evaluate(ast, env)).to eq(9)
	end

	it 'should evaluate all arguments when calling to function' do
		# When a functin is applied, the arguments should be evaluated before being bound
		# to the parameter names.
		env = Environment.new
		closure = evaluate(parse("(lambda (a) (+ a 5))"), env)
		ast = [closure, parse("(if #f 0 (+ 10 10))")]

		expect(evaluate(ast,env)).to eq(25)
	end

	it 'should evaluate the body in the env from the closure' do
		# The function's free variables, i.e. those not specified as part of the parameter list,
		# should be looked up in the environment from where the function was defined. This is
		# the env included in the closure. Make sure this environment is used when evaluating the body.
		closure = evaluate(parse("(lambda (x) (+ x y))"), Environment.new({"y" => 1}))
		ast = [closure, 0]
		result = evaluate(ast, Environment.new({"y" => 2}))

		expect(result).to eq(1)
	end
end


# Okay, now we're able to evaluate ASTs with closures as the first element. But normally the closures
# don't just happen to be there all by themselves. Generally we'll find some expression, evaluate it to
# a closure, and then evaluate a new AST with teh closure just like we did above
#
# (some-exp arg1 arg2 ...) -> (closure arg1 arg2 ...) -> result-of-function-call 


describe 'Lambda' do
	it 'should call very simple function in env' do
		# A call to a symbol correpsonds to a call to its value in the environment.
		#
		# When a symbol is the first element of the AST list, it is resolved to its value 
		# the environment (which should be a function closure). An AST with the variables
		# replaced with its value should then be evaluated instead.
		env = Environment.new
		evaluate(parse("(define add (lambda (x y) (+ x y)))"), env)
		expect(env.lookup("add")).to be_a Closure

		result = evaluate(parse("(add 1 2)"), env)
		expect(result).to eq(3)
	end

	it 'should be able to be defined and called directly' do
		# A lambda definition in the call position of an AST should be evaluated,
		# and then evaluated as before.
		ast = parse("((lambda (x) x) 42)")
		result = evaluate(ast, Environment.new)
		expect(result).to eq(42)
	end

	it 'should call complex expression which evaluates to function' do
		# Actually, all ASTs that are not atoms should be evaluated and then called.
		# 
		# In this test, a call is done to the if-expression. The 'if' should be evlauated,
		# which will result in a 'lambda' expressions. The lambda is evaluated, giving a 
		# closure. The result is an AST with a 'closure' as the first element, which we
		# already know how to evaluate.
		ast = parse("((if #f wont-evaluate-this-branch (lambda (x) (+ x y))) 2)")
		env = Environment.new({"y" => 3})
		expect(evaluate(ast, env)).to eq(5)
	end
#
# Now that we have the happy cases working, let's see what happen when functions calls are done incorrectly
#

	it 'should result in an error when calling a non-function' do
		expect{evaluate(parse("(#t 'foo 'bar)"), Environment.new)}.to raise_error(LispError, "not a function")
		expect{evaluate(parse("(42)"), Environment.new)}.to raise_error(LispError, "not a function")
	end

	it 'should make sure arguments are evaluated' do
		# The arguments passed to functions should be evaluated.
		# 
		# We should accepts parameters that are produced through function
		# calls. If you are seeing stack overflows, e.g. RuntimeError
		# then you should double-check that you are properly evaluating the passed function arguments.
		env = Environment.new
		res = evaluate(parse("((lambda (x) x) (+ 1 2))"), env)
		expect(res).to eq(3)
	end

	it 'should raise exceptions when called with wrong number of arguments' do
		env = Environment.new
		evaluate(parse("(define fn (lambda (p1 p2) 'whatever))"), env)
		expect{evaluate(parse("(fn 1 2 3)"), env)}.to raise_error(LispError, "wrong number of arguments, expected 2 got 3")
	end

#
# One final test to see that recursive functions are working as expected.
# The good news : this should already work by now :)
#	

	it 'should be recursive' do
		env = Environment.new
		evaluate(parse("(define my-fn (lambda (x) (if (eq x 0) 42 (my-fn (- x 1)))))"), env)
		expect(evaluate(parse('(my-fn 0)'), env)).to eq(42)
		expect(evaluate(parse('(my-fn 10)'), env)).to eq(42)
	end
end