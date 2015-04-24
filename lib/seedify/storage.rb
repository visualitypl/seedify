module Seedify
  module Storage
    class << self
      def seed_directory
        begin
          Rails.application.config.seedify_seed_directory || raise
        rescue
          Rails.root.join('db', 'seeds')
        end
      end

      def seed_list
        @all_seeds ||= Dir[File.join(seed_directory, '**', '*_seed.rb')].map do |file|
          ActiveSupport::Inflector.classify(file.sub(/^#{seed_directory.to_s + "/"}/, '').sub(/#{".rb"}$/, ''))
        end
      end
    end
  end
end
