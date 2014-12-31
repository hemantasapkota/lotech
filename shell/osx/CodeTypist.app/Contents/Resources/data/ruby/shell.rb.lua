return [=[
module TTY
  class Shell
    attr_reader :input

    attr_reader :output

    attr_reader :prefix

    def initialize(input = stdin, output = stdout, options = {})
      @input  = input
      @output = output
      @prefix = options.fetch(:prefix) { '' }
    end

    def ask(statement, *args, &block)
      options = Utils.extract_options!(args)

      question = Question.new self, options
      question.instance_eval(&block) if block_given?
      question.prompt(statement)
    end

    def yes?(statement, *args, &block)
      ask(statement, *args, &block).read_bool
    end

    def no?(statement, *args, &block)
      !yes?(statement, *args, &block)
    end

    def say(message = '', options = {})
      message = message.to_str
      return unless message.length > 0

      statement = Statement.new(self, options)
      statement.declare message
    end

    def confirm(*args)
      options = Utils.extract_options!(args)
      args.each { |message| say message, options.merge(color: :green) }
    end

    def warn(*args)
      options = Utils.extract_options!(args)
      args.each { |message| say message, options.merge(color: :yellow) }
    end

    def error(*args)
      options = Utils.extract_options!(args)
      args.each { |message| say message, options.merge(color: :red) }
    end

    def suggest(message, possibilities, options = {})
      suggestion = Suggestion.new(options)
      say(suggestion.suggest(message, possibilities))
    end

    def print_table(*args, &block)
      options  = Utils.extract_options!(args)
      renderer = options.fetch(:renderer) { :basic }
      table    = TTY::Table.new(*args, &block)
      say table.render(renderer, options)
    end

    def tty?
      stdout.tty?
    end

    def stdin
      $stdin
    end

    def stdout
      $stdout
    end

    def stderr
      $stderr
    end
  end
end
]=]
