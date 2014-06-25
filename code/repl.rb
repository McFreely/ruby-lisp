require_relative 'types'
require_relative 'parser'
require_relative 'interpreter'

def repl
    puts
    puts("              "          + faded("                              \\`.     T "))
    puts("  Welcome to   " + faded("  .--------------.____________) \\    |    T "))
    puts(" the DIY-lisp "    + faded("   |//////////////|____________[ ]    ! T  | "))
    puts("     REPL    "      + faded("    `--------------'            ) (      |  ! "))
    puts("              "          + faded("                               '-'      ! "))
    puts(faded(" use ^C to exit"))
    puts

    env = Environment.new
    interpret_file("stdlib.diy", env)

    while true
    	begin
    		source = read_expression
    		puts interpret(source, env)
    	rescue LispError => ex
    		puts colored("!", "red") + " " + faded(ex.class.name) + " :"
    		puts ex.to_s
    	rescue Interrupt
    		msg = " : Interrupted by user "
                          puts  msg
                          puts faded("Bye!")
                          exit
    	rescue Exception => ex
    		puts colored("! ", "red") + faded("The Ruby is shining through...")
    		puts faded("  " + ex.class.name + ": ")
                         raise ex
                         exit
    	end
    end
end

def read_expression
	# read from stdin until we have at least one s-expression
	exp = ""
	open_parens = 0
	while true
                          if exp.strip.empty?
                              line, parens = read_line("~> ")
                          else 
                              line, parens = read_line("... ")
		end
		open_parens += parens
		exp += line
		break if exp.strip && open_parens <= 0
	end

	exp.strip
end

def read_line(prompt)
             print colored(prompt, "blue", "bold")
	line = gets
	line = remove_comments(line + " \n")
	return line, line.count("(") - line.count(")")
end

def colored(text, color, attri=nil)
    attributes = {
            "bold" => 1,
            "dark" => 2
    }

    colors = {
        'grey' => 30,
        'red' => 31,
        'green' => 32,
        'yellow' => 33,
        'blue' => 34,
        'magenta' => 35,
        'cyan' => 36,
        'white' => 37,
        'reset' => 0
    }

    format = "\033[%dm"

    text if ENV['ANSI_COLORS_DISABLED']

    color = format % colors[color]
    if attri.nil?
        attri = String.new
    else
        attri = format % attributes[attri]
    end
    reset = format % colors['reset'] 
    return color + attri + text + reset
end

def faded(text)
     colored(text, "grey", attri="bold")
end