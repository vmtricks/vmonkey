require_relative 'spec_helper'

describe RbVmomi::VIM do
  before :all do
    @monkey ||= VMonkey.connect
    @template ||= @monkey.vm! VM_SPEC_OPTS[:template_path]
  end

  describe '#folder' do
    subject { @folder ||= @monkey.folder VM_SPEC_OPTS[:working_folder] }

    it { should_not be_nil }
    its(:name) { should == VM_SPEC_OPTS[:working_folder].split('/').last }
  end

  describe '#folder!' do
    it 'should raise a RuntimeError given a path to a non-existent folder' do
      expect { @monkey.folder! '/xyzzy' }.to raise_error RuntimeError
    end
  end

  describe '#vm' do
    subject { @vm ||= @monkey.vm VM_SPEC_OPTS[:template_path] }

    it { should_not be_nil }
    its(:name) { should == VM_SPEC_OPTS[:template_path].split('/').last }
  end

  describe '#vm!' do
    it 'should raise a RuntimeError given a path to a non-existent vm' do
      expect { @monkey.vm! '/xyzzy' }.to raise_error RuntimeError
    end
  end

  context 'with a cloned VM' do
    before(:all) do
      @vm_path = "#{VM_SPEC_OPTS[:working_folder]}/vmonkey_vim_spec"
      @spec_vm = @template.clone_to @vm_path
    end
    after(:all)  { @spec_vm.destroy }

    describe '#vm_by_uuid' do
      before(:all) { @uuid ||= @spec_vm.config.uuid }
      subject { @vm ||= @monkey.vm_by_uuid @uuid }

      it { should_not be_nil }
      its(:name) { should == @spec_vm.name }
    end

    describe '#vm_by_uuid!' do
      it 'should raise a RuntimeError given a UUID of a non-existent vm' do
        expect { @monkey.vm_by_uuid! 'xyzzy' }.to raise_error RuntimeError
      end
    end

    describe '#vm_by_instance_uuid' do
      before(:all) { @instance_uuid ||= @spec_vm.config.instanceUuid }
      subject { @vm ||= @monkey.vm_by_instance_uuid @instance_uuid }

      it { should_not be_nil }
      its(:name) { should == @spec_vm.name }
    end

    describe '#vm_by_instance_uuid!' do
      it 'should raise a RuntimeError given a UUID of a non-existent vm' do
        expect { @monkey.vm_by_instance_uuid! 'xyzzy' }.to raise_error RuntimeError
      end
    end
  end

  describe '#vapp' do
    subject { @vapp ||= @monkey.vapp VM_SPEC_OPTS[:vapp_path] }

    it { should_not be_nil }
    its(:name) { should == VM_SPEC_OPTS[:vapp_path].split('/').last }
  end

  describe '#vapp!' do
    it 'should raise a RuntimeError given a path to a non-existent vapp' do
      expect { @monkey.vapp! '/xyzzy' }.to raise_error RuntimeError
    end
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

  describe '#datastore' do
    context 'given an existing datastore' do
      subject { @ds ||= @monkey.datastore VM_SPEC_OPTS[:datastore] }
      it { should_not be_nil }
      its(:name) { should == VM_SPEC_OPTS[:datastore] }
    end
  end

  describe '#datastore!' do
    it 'should raise a RuntimeError given a non-existent datastore' do
      expect { @monkey.datastore! '/xyzzy' }.to raise_error RuntimeError
    end
  end


end