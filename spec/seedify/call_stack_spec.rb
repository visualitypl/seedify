require 'spec_helper'

describe Seedify::CallStack do
  it 'returns proper item from #last before, during and after #call' do
    last = nil
    proc = Proc.new { last = Seedify::CallStack.last }

    Seedify::CallStack.call(proc)

    expect(last).to eq proc
    expect(Seedify::CallStack.last).to eq nil
  end
end
