# This module holds some types we'll have use for along the way.
#
# It's your job to implement the Closure and Environment types.
# require 'pry'

class LispError < StandardError
end

class Closure
	def init(env, params, body)
		raise NotImplementError, "Do it Yourself"
	end

	def str
		return "<closure/%d>" % (self.params).length
	end
end

class Environment
	attr_accessor :variables

	def initialize(variables={})
		# There is a way to refactor this that elludes me at the moment
		@variables = variables
	end

	def lookup(symbol)
		# binding.pry
		if @variables[symbol].nil?
			raise LispError, "%s" % symbol
		else
			@variables[symbol]
		end
	end

	def extend(variables)
		return self.class.new(@variables.merge(variables))
	end

	def set(symbol, value)
		if @variables.has_key?(symbol)
			raise LispError, "Variable already defined"
		else 
			@variables[symbol] = value
		end
	end
end
