require 'simplecov'
require 'scrutinizer/ocular'
require "scrutinizer/ocular/formatter"
require "codeclimate-test-reporter"

CodeClimate::TestReporter.configuration.logger = Logger.new("/dev/null")

if Scrutinizer::Ocular.should_run? ||
    CodeClimate::TestReporter.run? ||
    ENV["COVERAGE"]
  formatters = [SimpleCov::Formatter::HTMLFormatter]
  if Scrutinizer::Ocular.should_run?
    formatters << Scrutinizer::Ocular::UploadingFormatter
  end
  if CodeClimate::TestReporter.run?
    formatters << CodeClimate::TestReporter::Formatter
  end
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]

  CodeClimate::TestReporter.configuration.logger = nil

  SimpleCov.start do
    add_filter "/lib/seedify.rb"
    add_filter "/lib/seedify/railtie.rb"
    add_filter "/spec/"
    add_filter "vendor"
  end
end

require_relative '../lib/seedify'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:each) do
    Object.send(:remove_const, :RailsRoot) if defined?(RailsRoot)
    Object.send(:remove_const, :Rails) if defined?(Rails)
    Object.send(:remove_const, :Seed) if defined?(Seed)
  end
end
