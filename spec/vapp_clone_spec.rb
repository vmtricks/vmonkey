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

    describe '#clone_to' do
      context 'to a Folder' do
        subject { @monkey.vapp @spec_vapp_path }
        it { should_not be_nil }
      end

      it 'should raise an error when given a path of an existing vApp' do
        expect { @spec_vapp.clone_to @spec_vapp_path }.to raise_error
      end
    end

    describe '#clone_to!' do
      before(:all) do
        @other_path = "#{@spec_vapp_path}-other"
        @other_vapp = @spec_vapp.clone_to @other_path
      end

      after(:all) do
        other_vapp = @monkey.vapp @other_path
        other_vapp.destroy if other_vapp
      end

      it 'should overwrite a vApp when given a path of an existing vApp' do
        @spec_vapp.clone_to! @other_path
        expect(@monkey.vapp @other_path).to_not be_nil
      end
    end
  end
end