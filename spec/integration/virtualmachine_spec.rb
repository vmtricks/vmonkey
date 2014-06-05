require_relative 'spec_helper'

describe RbVmomi::VIM::VirtualMachine do
  before :all do
    @monkey ||= VMonkey.connect
    @template = @monkey.vm VM_SPEC_OPTS[:template_path]
    @spec_vm = "#{VM_SPEC_OPTS[:working_folder]}/vmonkey_spec"
  end

  describe '#clone_params' do
    context 'with Folder destination' do
      subject { @params ||= @template.clone_params(@spec_vm.basename, @monkey.get(@spec_vm.parent), {}) }

      it { expect(subject[:name]).to eq @spec_vm.basename }
      it { expect(subject[:folder].name).to eq @spec_vm.parent.basename }
      it { expect(subject[:spec].powerOn).to eq false }
      it { expect(subject[:spec].template).to eq false }
      it { expect(subject[:spec].location.pool.name).to eq 'Resources' }
    end

    context 'with vApp destination' do
      subject { @params ||= @template.clone_params(@spec_vm.basename, @monkey.vapp(VM_SPEC_OPTS[:vapp_path]), {}) }

      it { expect(subject[:name]).to eq @spec_vm.basename }
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
          @template.clone_params(
            @spec_vm.basename,
            @monkey.get(@spec_vm.parent),
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

  describe '#clone' do
    context 'to a Folder' do
      before :all do
        @template.clone_to @spec_vm
      end

      subject { @monkey.vm @spec_vm }

      it { should_not be_nil }

      after :all do
        (@monkey.vm @spec_vm).destroy
      end
    end

    context 'to a vApp' do
      before :all do
        @vm_name_in_vapp = "#{@spec_vm.basename}-vapp"
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