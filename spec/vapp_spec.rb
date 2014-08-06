require_relative 'spec_helper'
using VMonkey

describe RbVmomi::VIM::VirtualApp do

  before :all do
    @monkey   ||= VMonkey.connect
    @vapp     ||= @monkey.vapp VM_SPEC_OPTS[:vapp_path]
    @spec_vapp_path = "#{VM_SPEC_OPTS[:working_folder]}/vmonkey_spec_vapp"
  end

  describe '#vm_pool' do
    subject { @vapp.vm_pool }
    it { should_not be_nil }
  end

  describe '#_clone_params' do
    context 'with Folder destination' do
      subject { @params ||= @vapp._clone_params(@spec_vapp_path.basename, @monkey.get(@spec_vapp_path.parent), {}) }

      it { expect(subject[:name]).to eq @spec_vapp_path.basename }
      it { expect(subject[:spec].location).to be_nil }
      it { expect(subject[:spec].vmFolder.name).to eql @spec_vapp_path.parent.basename }
    end
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
      end

      it { expect(@spec_vapp.property :prop).to eq 'xyzzy' }
      it { expect(@spec_vapp.property :prop2).to eq 'abc456' }
      it { expect(@spec_vapp.property :xyzzy).to be_nil }
    end

  end

end