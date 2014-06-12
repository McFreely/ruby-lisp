require './interpreter'
require './types'



describe 'Standard Lib' do
	before(:all) do
		env = Environment.new
		interpret_file('stdlib.diy', env)
	end

	it 'implements the not operator' do
		expect(interpret("(not #f)")).to eq("#t")
		expect(interpret("(not #t)")).to eq("#f")
	end

	it 'implements the or operator' do
		expect(interpret("(or #f #f)")).to eq("#f")
		expect(interpret("(or #t #f)")).to eq("#t")
		expect(interpret("(or #f #t)")).to eq("#t")
		expect(interpret("(or #t #t)")).to eq("#t")
	end

	it 'implements the and operator' do
		expect(interpret("(and #f #f)")).to eq("#f")
		expect(interpret("(and #t #f)")).to eq("#f")
		expect(interpret("(and #f #t)")).to eq("#f")
		expect(interpret("(and #t #t)")).to eq("#t")
	end
end