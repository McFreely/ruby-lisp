# This module holds some types we'll have use for along the way.
#
# It's your job to implement the Closure and Environment types.

class LispError < StandardError
end

class Clojure
	def init(env, params, body)
		raise NotImplementError, "Do it Yourself"
	end

	def str
		return "<closure/%d>" % (self.params).length
	end
end

class Environment
	def init()
		# There is a way to refactor this that elludes me at the moment
		self.variables = variables if variables else {}
	end

	def lookup(symbol)
		raise NotImplementError, "Do it Yourself"
	end

	def extend(variables)
		raise NotImplementError, "Do it Yourself"
	end

	def set(symbol, value)
		raise NotImplementError, "Do it Yourself"
	end
end
