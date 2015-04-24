module Seedify
  class Logger
    attr_reader :context

    def self.seed_name_formatter(name)
      name.to_s.sub(/Seed$/, '')
    end

    def self.max_seed_name_length
      @max_seed_name_length ||= Seedify::Storage.seed_list.map do |name|
        seed_name_formatter(name).length
      end.max
    end

    def initialize(context)
      @context = context
    end

    def line(message, &block)
      print "#{name} #{formatted_message message}"
      yield if block_given?
      print "\n"
    end

    def each(array, message, &block)
      process_items(array, array.length, message, &block)
    end

    def times(count, message, &block)
      process_items(count.times.to_a, count, message, &block)
    end

    private

    def process_items(array, count, message, &block)
      if count > 0
        done_count = yield_with_count(array, count, message, &block)
        all_done   = done_count == count
        eraser     = ' ' * (count.to_s.length - done_count.to_s.length)

        print "\r#{name} #{formatted_message message} " +
          colorize("#{done_count}/#{count}", all_done ? 35 : 31) + eraser
      else
        print "\r#{name} #{formatted_message message} #{colorize 'NONE', 31}"
      end

      print "\n"
    end

    def yield_with_count(array, count, message)
      done_count = 0
      array.each_with_index do |item, index|
        percent = (index * 100) / count
        print "\r#{name} #{formatted_message message} #{colorize "#{index + 1}/#{count}", 35}"

        done_count += 1 if yield(item) != false
      end

      done_count
    end

    def formatted_message(message)
      message = colorize_pairs message, '*', 93
      message = colorize_pairs message, "'", 92
      message = colorize_pairs message, '"', 96

      message
    end

    def colorize(message, code)
      "\033[#{code}m#{message}\033[0m"
    end

    def colorize_pairs(message, quote, code)
      quote = '\\' + quote
      message.gsub(/#{quote}(.*?)#{quote}/) do |match|
        colorize(match.sub(/^#{quote}/, '').sub(/#{quote}$/, ''), code)
      end
    end

    def print(message)
      Kernel.print(message) if context.log?
    end

    def name
      text = self.class.seed_name_formatter(context.class)
      text = (' ' * [0, self.class.max_seed_name_length - text.length].max) + text

      colorize(text, 32)
    end
  end
end
