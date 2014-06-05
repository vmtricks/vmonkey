require_relative 'spec_helper'

describe RbVmomi::VIM::VirtualMachine do
  before :all do
    @monkey ||= VMonkey.connect
    @template = @monkey.vm VM_SPEC_OPTS[:template_path]
    @vm_path = "#{VM_SPEC_OPTS[:working_folder]}/vmonkey_spec"
  end

  describe '#_clone_params' do
    context 'with Folder destination' do
      subject { @params ||= @template._clone_params(@vm_path.basename, @monkey.get(@vm_path.parent), {}) }

      it { expect(subject[:name]).to eq @vm_path.basename }
      it { expect(subject[:folder].name).to eq @vm_path.parent.basename }
      it { expect(subject[:spec].powerOn).to eq false }
      it { expect(subject[:spec].template).to eq false }
      it { expect(subject[:spec].location.pool.name).to eq 'Resources' }
    end

    context 'with vApp destination' do
      subject { @params ||= @template._clone_params(@vm_path.basename, @monkey.vapp(VM_SPEC_OPTS[:vapp_path]), {}) }

      it { expect(subject[:name]).to eq @vm_path.basename }
      it { expect(subject[:folder].name).to eq VM_SPEC_OPTS[:vapp_path].parent.basename }
      it { expect(subject[:spec].powerOn).to eq false }
      it { expect(subject[:spec].template).to eq false }
      it { expect(subject[:spec].location.pool.name).to eq VM_SPEC_OPTS[:vapp_path].basename }

      it { expect(subject[:spec].customization).to be_nil }
      it { expect(subject[:spec].config.annotation).to be_nil }
      it { expect(subject[:spec].config.numCPUs).to be_nil }
      it { expect(subject[:spec].config.memoryMB).to be_nil }
    end

    context 'with config' do
      subject do
        @params ||=
          @template._clone_params(
            @vm_path.basename,
            @monkey.get(@vm_path.parent),
            customization_spec: VM_SPEC_OPTS[:customization_spec],
            config: {
              annotation: 'an annotation',
              num_cpus: 3,
              memory_mb: 1024
            })
      end

      it { expect(subject[:spec].customization).to_not be_nil }
      it { expect(subject[:spec].config.annotation).to eq 'an annotation' }
      it { expect(subject[:spec].config.numCPUs).to eq 3 }
      it { expect(subject[:spec].config.memoryMB).to eq 1024 }
    end
  end

  context 'with a cloned VM' do
    before(:all) { @spec_vm = @template.clone_to @vm_path }
    after(:all)  { @spec_vm.destroy }

    describe '#clone' do
      context 'to a Folder' do
        subject { @monkey.vm @vm_path }
        it { should_not be_nil }
      end
    end

    describe '#property' do
      before(:all) do
        @spec_vm.property :spec_prop, 'xyzzy'
        @spec_vm.property :spec_prop2, 'abc123'
        @spec_vm.property :spec_prop2, 'abc456'
      end

      subject { @spec_vm }
      it { expect(@spec_vm.property :spec_prop).to eq 'xyzzy' }
      it { expect(@spec_vm.property :spec_prop2).to eq 'abc456' }
      it { expect(@spec_vm.property :spec_non_existent).to be_nil }
    end
  end

  describe '#clone' do
    context 'to a vApp' do
      before :all do
        @vm_name_in_vapp = "#{@vm_path.basename}-vapp"
        @template.clone_to "#{VM_SPEC_OPTS[:vapp_path]}/#{@vm_name_in_vapp}"
        @spec_vapp = @monkey.vapp VM_SPEC_OPTS[:vapp_path]
      end

      subject { @spec_vapp.find_vm @vm_name_in_vapp }

      it { should_not be_nil }

      after :all do
        (@spec_vapp.find_vm @vm_name_in_vapp).destroy
      end
    end
  end

end