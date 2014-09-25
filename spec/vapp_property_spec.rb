require_relative 'spec_helper'
using VMonkey unless RUBY_VERSION.split('.')[0] == '1'

describe RbVmomi::VIM::VirtualApp do

  before :all do
    @monkey   ||= VMonkey.connect
    @vapp     ||= @monkey.vapp VM_SPEC_OPTS[:vapp_path]
    @spec_vapp_path = "#{VM_SPEC_OPTS[:working_folder]}/vmonkey_spec_vapp"
  end

  context 'with a cloned vapp' do
    before(:all) { @spec_vapp = @vapp.clone_to @spec_vapp_path }
    after(:all)  { @spec_vapp.destroy }

    describe '#clone' do
      context 'to a Folder' do
        subject { @monkey.vapp @spec_vapp_path }
        it { should_not be_nil }
      end
    end

    describe '#annotation=' do
      it 'sets the annotation' do
        @spec_vapp.annotation = 'xyzzy'
        expect(@spec_vapp.annotation).to eq 'xyzzy'
      end
    end

    describe '#property' do
      before(:all) do
        @spec_vapp.property :prop, 'xyzzy'
        @spec_vapp.property :prop2, 'abc123'
        @spec_vapp.property :prop2, 'abc456'
        @spec_vapp.property :ip_prop, nil, type: 'ip'
        @spec_vapp.property :ip_prop_with_default, nil, type: 'ip', defaultValue: '0.0.0.0'
      end

      it { expect(@spec_vapp.property :prop).to eq 'xyzzy' }
      it { expect(@spec_vapp.property :prop2).to eq 'abc456' }
      it { expect(@spec_vapp.property :xyzzy).to be_nil }

      it { expect(@spec_vapp.property :ip_prop).to be_empty }
      it { expect(@spec_vapp.find_property(:ip_prop)[:type]).to eq 'ip' }

      it { expect(@spec_vapp.property :ip_prop_with_default).to eq '0.0.0.0' }
      it { expect(@spec_vapp.find_property(:ip_prop_with_default)[:type]).to eq 'ip' }
    end

    describe '#set_properties' do
      before(:all) do
        @spec_vapp.set_properties({
            multi_prop: 'xyzzy',
            multi_ip_prop: { value: '1.1.1.1', type: 'ip' },
            multi_ip_prop_with_default: { value: nil, type: 'ip', defaultValue: '0.0.0.0' }
          })
      end

      it 'should set multiple properies from scratch' do
        expect(@spec_vapp.property :multi_prop).to eq 'xyzzy'
        expect(@spec_vapp.property :multi_ip_prop).to eq '1.1.1.1'
        expect(@spec_vapp.property :multi_ip_prop_with_default).to eq '0.0.0.0'
      end

      it 'should overwrite multiple properies that already exist' do
        @spec_vapp.set_properties({
            multi_prop: 'abc123',
            multi_ip_prop: '2.2.2.2',
            multi_ip_prop_with_default: { value: '3.3.3.3', type: 'string' }
          })

        expect(@spec_vapp.property :multi_prop).to eq 'abc123'
        expect(@spec_vapp.property :multi_ip_prop).to eq '2.2.2.2'
        expect(@spec_vapp.find_property(:multi_ip_prop)[:type]).to eq 'ip'
        expect(@spec_vapp.property :multi_ip_prop_with_default).to eq '3.3.3.3'
        expect(@spec_vapp.find_property(:multi_ip_prop_with_default)[:type]).to eq 'string'
      end
    end
  end
end