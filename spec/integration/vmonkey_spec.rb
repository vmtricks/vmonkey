require_relative 'spec_helper'

describe VMonkey do
  describe '#connect' do
    subject { @vim ||= VMonkey.connect }

    it { should_not be_nil }
    its(:dc) { should_not be_nil }
  end
end