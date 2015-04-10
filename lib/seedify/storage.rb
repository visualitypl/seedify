module Seedify
  module Storage
    class << self
      def seed_directory
        Rails.root.join('app', 'seeds')
      end

      def seed_list
        @all_seeds ||= Dir[File.join(seed_directory, '**', '*_seed.rb')].map do |file|
          ActiveSupport::Inflector.classify(file.sub(/^#{seed_directory.to_s + "/"}/, '').sub(/#{".rb"}$/, ''))
        end
      end

      def max_seed_name_length
        @max_seed_name_length ||= seed_list.map(&:length).max
      end
    end
  end
end
