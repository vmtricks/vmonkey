require_relative 'spec_helper'

describe RbVmomi::VIM do
  describe '#folder' do
    subject { @folder ||= VMonkey.connect.folder '/Templates' }

    it { should_not be_nil }
    its(:name) { should == 'Templates' }
  end
end