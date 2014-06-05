require_relative 'spec_helper'

describe RbVmomi::VIM::Folder do

  before :all do
    @monkey ||= VMonkey.connect
    @vapp ||= @monkey.vapp VM_SPEC_OPTS[:vapp_path]
  end

  describe '#vm_pool' do
    subject { @vapp.vm_pool }
    it { should_not be_nil }
  end
end