require_relative 'spec_helper'

describe RbVmomi::VIM do
  before :all do
    @monkey ||= VMonkey.connect
  end

  describe '#folder' do
    subject { @folder ||= @monkey.folder VM_SPEC_OPTS[:working_folder] }

    it { should_not be_nil }
    its(:name) { should == VM_SPEC_OPTS[:working_folder].split('/').last }
  end

  describe '#vm' do
    subject { @vm ||= @monkey.vm VM_SPEC_OPTS[:template_path] }

    it { should_not be_nil }
    its(:name) { should == VM_SPEC_OPTS[:template_path].split('/').last }
  end

  describe '#vapp' do
    subject { @vapp ||= @monkey.vapp VM_SPEC_OPTS[:vapp_path] }

    it { should_not be_nil }
    its(:name) { should == VM_SPEC_OPTS[:vapp_path].split('/').last }
  end

  describe '#get' do
    context 'given a path to a real object' do
      subject { @get ||= @monkey.get VM_SPEC_OPTS[:working_folder] }

      it { should_not be_nil }
      its(:name) { should == VM_SPEC_OPTS[:working_folder].split('/').last }
    end

    context 'given a path to a non-existent object' do
      subject { @get_nil ||= @monkey.get '/xyzzy' }

      it { should be_nil }
    end
  end

  describe '#customization_spec' do
    context 'given an existing customization spec' do
      subject { @cspec ||= @monkey.customization_spec VM_SPEC_OPTS[:customization_spec] }

      it { should_not be_nil }
    end

    context 'given a non-existing customization spec' do
      subject { @cspec ||= @monkey.customization_spec 'xyzzy' }

      it { should be_nil }
    end

  end

end