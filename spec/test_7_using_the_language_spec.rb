require "minitest/autorun"

require './code/interpreter'
require './code/types'

describe 'Standard Lib' do
	let(:env) { env = Environment.new }
	before(:each) do
		interpret_file('stdlib.diy', env)
	end

	it 'implements the not operator' do
		assert_equal interpret("(not #f)", env), "#t"
		assert_equal interpret("(not #t)", env), "#f"
	end

	it 'implements the or operator' do
		assert_equal interpret("(or #f #f)"), "#f"
		assert_equal interpret("(or #t #f)"), "#t"
		assert_equal interpret("(or #f #t)"), "#t"
		assert_equal interpret("(or #t #t)"), "#t"
	end

	it 'implements the and operator' do
		assert_equal interpret("(and #f #f)"), "#f"
		assert_equal interpret("(and #t #f)"), "#f"
		assert_equal interpret("(and #f #t)"), "#f"
		assert_equal interpret("(and #t #t)"), "#t"
	end
end
