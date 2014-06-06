require_relative 'spec_helper'

describe RbVmomi::VIM::Folder do
  before :all do
    @monkey ||= VMonkey.connect
    @folder ||= @monkey.folder VM_SPEC_OPTS[:working_folder]
  end

  describe '#vm_pool' do
    subject { @folder.vm_pool }
    it { should_not be_nil }
  end
end