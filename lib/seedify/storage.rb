module Seedify
  module Storage
    class << self
      def seed_directory
        Rails.root.join('app', 'seeds')
      end

      def seed_list
        @all_seeds ||= Dir[seed_directory.join('**', '*_seed.rb')].map do |file|
          file.sub(/^#{seed_directory.to_s + "/"}/, '').sub(/#{".rb"}$/, '').classify
        end
      end

      def max_seed_name_length
        @max_seed_name_length ||= seed_list.map(&:length).max
      end
    end
  end
end
