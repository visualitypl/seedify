require 'spec_helper'

describe Seedify::ParamValue do
  let(:options) { { } }

  subject { Seedify::ParamValue.get(:seedify_param, options) }

  it { is_expected.to eq nil }

  context 'with default' do
    let(:options) { { default: 'x' } }

    it { is_expected.to eq 'x' }
  end

  context 'with type :integer' do
    let(:options) { { type: :integer } }

    it { is_expected.to eq 0 }
  end

  context 'with type :boolean' do
    let(:options) { { type: :boolean } }

    it { is_expected.to eq false }
  end

  context 'with type :integer and default' do
    let(:options) { { type: :integer, default: 1 } }

    it { is_expected.to eq 1 }
  end

  context 'with type :integer and default' do
    let(:options) { { type: :integer, default: 1 } }

    it { is_expected.to eq 1 }
  end

  context 'with type :integer and default as proc' do
    let(:options) { { type: :integer, default: -> { 2 } } }

    it { is_expected.to eq 2 }
  end

  context 'with type :integer, default and value in ENV' do
    let(:options) { { type: :integer, default: 1 } }

    before do
      ENV['seedify_param'] = '2'
    end

    it { is_expected.to eq 2 }
  end
end
