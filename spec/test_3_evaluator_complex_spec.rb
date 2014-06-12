require './evaluator'
require './types'
require './parser'

describe 'Complex evaluation' do
	env = Environment.new

	it 'should evaluate nested function' do
		# Remember, functions should evaluate their arguments
		#
		# Thus, nested expressions should work just fine without any
		# further work at this point.
		#
		# If this test is failing, make sure that '+', '>' and so on
		# is evaluating their arguments before operating on them.
		nested_expression = parse("(eq #f (> (- (+ 1 3) (* 2 (mod 7 4))) 4))")
		expect(evaluate(nested_expression, env)).to eq(true)
	end

	it 'should evaluate basic if statement' do
		# If statements are basic onctrol structure?
		#
		# The 'if' should first evaluate its first argument. If this evaluates
		# to true, then the second argument is evaluated and returned. Otherwise
		# the third and last argument is evaluated and returned instead.
		if_expression_one = parse("(if #t 42 1000)")
		expect(evaluate(if_expression_one, env)).to eq(42)

		if_expression_two = parse("(if #f 42 1000)")
		expect(evaluate(if_expression_two, env)).to eq(1000)

		if_expression_three = parse("(if #t #t #f)")
		expect(evaluate(if_expression_three, env)).to eq(true)
	end

	it 'should not evaluate the discarded branch in if statement' do
		# A final test with a more complex if expression
		# This test should already be passing if the above ones are.

		if_expression = parse('(if (> 1 2) (- 1000 1) (+ 40 (- 3 1)))')
		expect(evaluate(if_expression, env)).to eq(42)
	end
end