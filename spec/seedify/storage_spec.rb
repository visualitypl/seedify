require 'spec_helper'

describe Seedify::Storage do
  before do
    Object.send(:remove_const, :RailsRoot) if defined?(RailsRoot)
    Object.send(:remove_const, :Rails) if defined?(Rails)

    RailsRoot = Class.new do
      def self.join(*args)
        File.join('spec', 'fixtures', *args)
      end
    end

    Rails = OpenStruct.new(root: RailsRoot)
  end

  describe '#seed_directory' do
    subject { Seedify::Storage.seed_directory }

    it { is_expected.to eq 'spec/fixtures/db/seeds' }
  end

  describe '#seed_list' do
    subject { Seedify::Storage.seed_list }

    it { is_expected.to include 'ApplicationSeed' }
    it { is_expected.to include 'Admin::BlogPostSeed' }
  end
end
