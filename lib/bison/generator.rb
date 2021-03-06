class Generator

	def initialize(name)

		# Create file out output intermediate code

		@code = Array.new
		@line = 1

		@fileName = name
		@fileName << ".jam"	# append the file extesion
		#@file = File.open(name, 'w')

		@ifStack = Array.new	# Use to hold if statements that need to be back patched
		@whileStack = Array.new	# Use to hold while statements that need to be back patched
		@declareStack = Array.new # Use to reverse declarations
		@expStore	# Used to store expressions untill they are needed later

		@reg = [nil, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
		@i = 0 # Indicates if a register should be used

	end

	def gen(rule, token)

		case rule

			when 2	# Turn around the declarations
				@code.reverse!

			when 4 # ID data_type default ; declare_rest
				return unless token[2][1]	# only generate code if there is actually an anignment

				thisLine = ''
				if @i == 0
					thisLine << "STO "
					thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
					thisLine << "#{token[2][1]},, #{token[4][1]}"
					@code << thisLine
				else
					@code << "STO #{@reg[@i]},, #{token[4][1]}"
					@i -= 1
				end
				@line += 1

			when 24
				

			when 27
				@code << "SYS #-1, #{token[1][1]},"
				@line += 1
				@code << "SYS #0,,"
				@line += 1

			when 28
				@code << "SYS #-1, #{token[1][1]},"
				@line += 1

			when 29
				@code << "SYS #0,,"
				@line += 1

			when 30
				@code << "SYS #1, ,0"
				@line += 1

			when 31	# IF expression THEN statement END IF
				backPatch('if', @ifStack.pop, @line) if @ifStack.any?	# BackPatch the IF to jump to current line

			when 32	# WHILE expression LOOP statement END LOOP
				@code << "JMP , , ##{@whileStack[-2]-1}"
				@line += 1
				backPatch('while', @whileStack.pop, @line) if @ifStack.any?	# BackPatch the IF to jump to current line-1backPatch('while', @whileStack.pop, @line-1) if @ifStack.any?

			when 33	# ID := righthandside

				thisLine = ''
				if @i == 0
					thisLine << "STO "
					thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
					thisLine << "#{token[0][1]},, #{token[2][1]}"
					@code << thisLine
				else
					@code << "STO #{@reg[@i]},, #{token[2][1]}"
					@i = 0	# Formerly @i -= 1
				end
				@line += 1

			when 37
				thisLine = ''
				#@line -= 1	# I need this here because reasons
				case token[1][1]	# Op Codes at the inverse because that's just how op codes do
					when '>'
						thisLine << "JGT "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, ##{@line+2}"
						@code << (thisLine)
						@ifStack.push(@line)	# Save to stack to be finished later
						@whileStack.push(@line)
					when '>='
						thisLine << "JGE "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, ##{@line+2}"
						@code << (thisLine)
						@ifStack.push(@line)	# Save to stack to be finished later
						@whileStack.push(@line)
					when '='
						thisLine << "JEQ "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, ##{@line+2}"
						@code << (thisLine)
						@ifStack.push(@line)	# Save to stack to be finished later
						@whileStack.push(@line)
					when '<='
						thisLine << "JGE "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, ##{@line+2}"
						@code << (thisLine)
						@ifStack.push(@line)	# Save to stack to be finished later
						@whileStack.push(@line)
					when '<'
						thisLine << "JGT "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, ##{@line+2}"
						@code << (thisLine)
						@ifStack.push(@line)	# Save to stack to be finished later
						@whileStack.push(@line)
					when '<>'
						thisLine << "JNE "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, ##{@line+2}"
						@code << (thisLine)
						@ifStack.push(@line)	# Save to stack to be finished later
						@whileStack.push(@line)
				end
				#@line += 1

				@code << "STO #0, , t"
				@line += 1

				@code << "JMP , , ##{@line+2}"
				@line += 1

				@code << "STO #1, , t"
				@line += 1

				@code << "JNE #1, t, "
				@ifStack.push(@line)
				@whileStack.push(@line)
				@line += 1

			when 39	# Simple_expression addop term
				@i += 1
				if token[1][1].eql? '+'
					if @i > 1
						thisLine = "ADD "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, #{@reg[@i-1]}, #{@reg[@i]}"
					else
						thisLine = "ADD "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, #{@reg[@i]}"
					end
					@code << thisLine
				elsif token[1][1].eql? '-'
					if @i > 1
						thisLine = "SUB #{@reg[@i-1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, #{@reg[@i]}"
					else
						thisLine = "SUB "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, #{@reg[@i]}"
					end
					@code << thisLine
				end
				@line += 1

			when 41	# term mulop factor
				@i += 1
				if token[1][1].eql? '*'
					if @i > 1
						thisLine = "MUL "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, #{@reg[@i-1]}, #{@reg[@i]}"
					else
						thisLine = "MUL "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, #{@reg[@i]}"
					end
					@code << thisLine
				elsif token[1][1].eql? '/'
					if @i > 1
						thisLine = "DIV #{@reg[@i-1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, #{@reg[@i]}"
					else
						thisLine = "DIV "
						thisLine << "\#" if (token[2][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[2][1]}, "
						thisLine << "\#" if (token[0][1] =~ /^[-+]?[0-9]+$/)	== 0	# This is a number
						thisLine << "#{token[0][1]}, #{@reg[@i]}"
					end
					@code << thisLine
				end
				@line += 1

			else
				#puts "#{rule}, #{token}"	# REMOVE

		end

	end

	def backPatch (stack, line, patch)

		if stack.eql? "if"
			@code[line].concat(" ##{patch}")
			@whileStack.pop

		elsif stack.eql? "while"
			@code[line].concat(" ##{patch}")
			@ifStack.pop

		end

	end

	def close
		@file = File.open(@fileName, 'w')
		lineNum = 0
		@code.each { |line| 
			@file.puts("#{lineNum} #{line}")	# Write each line to the file
			lineNum += 1
		}
		@file.puts("#{lineNum} HLT ,,")	# Add HALT to end of code

	end

end
