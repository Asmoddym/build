#!/usr/bin/ruby

module Options
	DEFAULT_BUILD_DIR = ".build"
	DEFAULT_CLEAN = false
	OPTIONS = {
		["--clean", "-c"] => ["cleanDirectoryBeforeBuild", false, "Cleans the building directory before build (default: #{DEFAULT_CLEAN})"],
		["-b", "--build-dir"] => ["setBuildDirectory", true, "Defines the building directory (default: \"#{DEFAULT_BUILD_DIR}\")"]
	}


	def isOption(arg)
		arg.slice(0...1) == "-" || arg.slice(0...2) == "--"
	end

	def takesParameter(option)
		OPTIONS.each {|options, data|
			return data[1] if options.include?(option)
		}
		false
	end

	def getMethod(option)
		OPTIONS.each {|options, data|
			return data[0] if options.include?(option)
		}
		nil
	end
end

class Help
	include Options
	def self.display
		puts "USAGE: #{__FILE__} [options...]"
		puts
		puts "OPTIONS (optional):"
		OPTIONS.each { |options, data|
			puts "  - #{options.to_s}: #{data[2]}"
		}
	end
end

class Commands
	attr_reader :clean
	attr_reader :build_dir

	def initialize
		@clean = Options::DEFAULT_CLEAN
		@build_dir = Options::DEFAULT_BUILD_DIR
	end

	def cleanDirectoryBeforeBuild(arg)
		@clean = !@clean
		true
	end

	def setBuildDirectory(arg)
		@build_dir = arg
		!@build_dir.nil?
	end
end

class Builder
	def build(clean, build_dir)
		puts "clean: #{clean}"
		puts "build_dir: #{build_dir}"
	end
end

class Arguments
	include Options
	def parse
		@takes_arg = false
		commands = Commands.new
		for i in 0...ARGV.length
			if @takes_arg
				@takes_arg = false
				next
			elsif isOption(ARGV[i])
				m = getMethod(ARGV[i])
				return false if m.nil? or !commands.respond_to? m
				@takes_arg = takesParameter(ARGV[i])
				return false if !commands.send(m, takesParameter(ARGV[i]) ? ARGV[i + 1] : nil)
			end
		end
		builder = Builder.new
		builder.build(commands.clean, commands.build_dir)
		true
	end
end

args = Arguments.new

if !args.parse
	Help.display
end