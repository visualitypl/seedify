require 'spec_helper'

describe Seedify::Base do
  before do
    Object.send(:remove_const, :RailsRoot) if defined?(RailsRoot)
    Object.send(:remove_const, :Rails) if defined?(Rails)
    Object.send(:remove_const, :Seed) if defined?(Seed)

    RailsRoot = Class.new do
      def self.join(*args)
        File.join('spec', 'fixtures', *args)
      end
    end

    Rails = OpenStruct.new(root: RailsRoot)

    class Seed < Seedify::Base
      def self.called!
        @called = true
      end

      def self.called?
        @called == true
      end

      def call
        log('*x*')
        log_each([:a, :b], 'y') {}
        log_times(0, 'z') { }

        self.class.called!
      end
    end
  end

  it 'calls the #call instance method of seed object' do
    Seed.call(log: false)

    expect(Seed.called?).to eq true
  end

  it 'calls logger properly' do
    expect_any_instance_of(Seedify::Logger).to receive(:line).once
    expect_any_instance_of(Seedify::Logger).to receive(:each).once
    expect_any_instance_of(Seedify::Logger).to receive(:times).once

    Seed.call(log: false)
  end
end
