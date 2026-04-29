require 'erb'
require 'fileutils'

module FuseDevTools
  module Tasks
    class Base
      OptionParsingError = Class.new(StandardError)
      Command = Struct.new(:name, :description, :options)
      Option = Struct.new(:name, :description, :default)

      class << self
        def inherited subclass
          super
          subclass.instance_variable_set(:@commands, {})
          subclass.instance_variable_set(:@pending_options, [])
          subclass.instance_variable_set(:@last_command_name, nil)
        end

        def desc name, description
          commands[name.to_s] = Command.new(name.to_s, description, pending_options.dup)
          @pending_options = []
          @last_command_name = name.to_s
        end

        def option name, desc: nil, default: nil
          option = Option.new(name.to_s, desc, default)
          if @last_command_name && commands[@last_command_name]
            commands[@last_command_name].options << option
          else
            pending_options << option
          end
        end

        def commands
          @commands ||= {}
        end

        def pending_options
          @pending_options ||= []
        end

        def source_root path = nil
          @source_root = path if path
          @source_root
        end

        def start argv = []
          new.start(argv)
        end
      end

      attr_reader :options

      def initialize
        @options = {}
      end

      def start argv = []
        argv = argv.dup
        return help if argv.empty? || help_argument?(argv.first)

        command_name = argv.shift.to_s
        command = self.class.commands[command_name]
        return unknown_command(command_name) unless command
        return command_help(command) if argv.any? { |arg| help_argument?(arg) }

        @options = parse_options(argv, command.options)
        public_send(command.name)
      rescue OptionParsingError => e
        warn e.message
        say ''
        command_help(command)
        raise SystemExit, 1
      end

      def help
        say 'Commands:'
        self.class.commands.each_value do |command|
          say format('  %<name>-28s %<description>s', name: command.name, description: command.description)
        end
      end

      def command_help command
        say "Usage: #{command.name} [options]"
        say ''
        say command.description
        return if command.options.empty?

        say ''
        say 'Options:'
        command.options.each do |option|
          aliases = "--#{option.name.tr('_', '-')}, --#{option.name}"
          default = option.default.nil? ? '' : " (default: #{option.default})"
          say format(
            '  %<aliases>-36s %<description>s%<default>s',
            aliases: aliases,
            description: option.description,
            default: default
          )
        end
      end

      def say message = ''
        puts message
      end

      def ask question
        print "#{question} "
        $stdin.gets.to_s.chomp
      end

      def yes? question
        ask(question).match?(/\Ay(?:es)?\z/i)
      end

      def create_file path, contents
        FileUtils.mkdir_p File.dirname(path)
        File.write path, contents
      end

      def template source, destination, config = {}
        template_path = File.join(self.class.source_root, source)
        rendered = ERB.new(File.read(template_path)).result(binding)
        create_file destination, rendered
      end

      private

        def help_argument? argument
          %w[-h --help help].include? argument.to_s
        end

        def parse_options argv, option_definitions
          option_aliases = aliases_for(option_definitions.map(&:name))
          parsed = defaults_for(option_definitions)
          parse_option_arguments!(argv, option_aliases, parsed)
          parsed
        end

        def unknown_command command_name
          warn "Unknown command: #{command_name}"
          help
          raise SystemExit, 1
        end

        def defaults_for option_definitions
          option_definitions.each_with_object({}) do |option, parsed|
            parsed[option.name] = option.default
            parsed[option.name.to_sym] = option.default
          end
        end

        def aliases_for names
          names.each_with_object({}) do |name, all_aliases|
            all_aliases[name] = name
            all_aliases[name.tr('_', '-')] = name
          end
        end

        def parse_option_arguments! argv, option_aliases, parsed
          index = 0
          index += parse_option_argument!(argv, index, option_aliases, parsed) while index < argv.length
        end

        def parse_option_argument! argv, index, option_aliases, parsed
          argument = argv[index]
          raise OptionParsingError, "Unexpected argument: #{argument}" unless argument.start_with?('--')

          raw_name, value = argument.sub(/\A--/, '').split('=', 2)
          canonical_name = option_aliases[raw_name]
          raise OptionParsingError, "Unknown option: --#{raw_name}" unless canonical_name

          value, consumed_next_value = read_option_value(argv, index, value, raw_name)
          parsed[canonical_name] = value
          parsed[canonical_name.to_sym] = value
          consumed_next_value ? 2 : 1
        end

        def read_option_value argv, index, existing_value, raw_name
          return [existing_value, false] if existing_value

          next_value = argv[index + 1]
          raise OptionParsingError, "Missing value for --#{raw_name}" if next_value.nil? || next_value.start_with?('--')

          [next_value, true]
        end
    end
  end
end
