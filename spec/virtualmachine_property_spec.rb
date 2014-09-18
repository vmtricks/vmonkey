require_relative 'spec_helper'
using VMonkey unless RUBY_VERSION.split('.')[0] == '1'

describe RbVmomi::VIM::VirtualMachine do
  before :all do
    @monkey ||= VMonkey.connect
    @template = @monkey.vm VM_SPEC_OPTS[:template_path]
    @vm_path = "#{VM_SPEC_OPTS[:working_folder]}/vmonkey_spec"
  end

  context 'with a cloned VM' do
    before(:all) { @spec_vm = @template.clone_to @vm_path }
    after(:all)  { @spec_vm.destroy }

    describe '#annotation=' do
      it 'sets the annotation' do
        @spec_vm.annotation = 'xyzzy'
        expect(@spec_vm.annotation).to eq 'xyzzy'
      end
    end

    describe '#property' do
      before(:all) do
        @spec_vm.property :prop, 'xyzzy'
        @spec_vm.property :prop2, 'abc123'
        @spec_vm.property :prop2, 'abc456'
        @spec_vm.property :ip_prop, nil, type: 'ip'
        @spec_vm.property :ip_prop_with_default, nil, type: 'ip', defaultValue: '0.0.0.0'
      end

      it { expect(@spec_vm.property :prop).to eq 'xyzzy' }
      it { expect(@spec_vm.property :prop2).to eq 'abc456' }
      it { expect(@spec_vm.property :xyzzy).to be_nil }

      it { expect(@spec_vm.property :ip_prop).to be_empty }
      it { expect(@spec_vm.find_property(:ip_prop)[:type]).to eq 'ip' }

      it { expect(@spec_vm.property :ip_prop_with_default).to eq '0.0.0.0' }
      it { expect(@spec_vm.find_property(:ip_prop_with_default)[:type]).to eq 'ip' }
    end

    describe '#property!' do
      it 'should raise a RuntimeError given a path to a non-existent property' do
        expect { @spec_vm.property! :xyzzy }.to raise_error RuntimeError
      end
    end
  end
end