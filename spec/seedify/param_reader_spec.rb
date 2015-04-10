require 'spec_helper'

describe Seedify::ParamReader do
  before do
    seed = @seed = Class.new
    seed.extend(Seedify::ParamReader)
    seed.param_reader(:email, default: 'a@b.c')
    seed.param_reader(:count, type: :integer)

    sub = @sub = Class.new(seed)
    sub.param_reader(:name, default: 'Name')
  end

  it 'stores all readers defined on class' do
    expect(@seed.get_param_readers).to have_key :email
    expect(@seed.get_param_readers[:email]).to have_key :default
    expect(@seed.get_param_readers[:email][:default]).to eq 'a@b.c'
    expect(@seed.get_param_readers).to have_key :count
    expect(@seed.get_param_readers[:count]).to have_key :type
    expect(@seed.get_param_readers[:count][:type]).to eq :integer
    expect(@seed.get_param_readers).not_to have_key :name
  end

  it 'stores all readers inherited from superclass among own ones' do
    expect(@sub.get_param_readers).to have_key :email
    expect(@sub.get_param_readers[:email]).to have_key :default
    expect(@sub.get_param_readers[:email][:default]).to eq 'a@b.c'
    expect(@sub.get_param_readers).to have_key :count
    expect(@sub.get_param_readers[:count]).to have_key :type
    expect(@sub.get_param_readers[:count][:type]).to eq :integer
    expect(@sub.get_param_readers).to have_key :name
    expect(@sub.get_param_readers[:name]).to have_key :default
    expect(@sub.get_param_readers[:name][:default]).to eq 'Name'
  end
end
