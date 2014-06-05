require_relative 'spec_helper'

describe 'RbVmomi::VIM' do
  before(:each) do
    module RbVmomi
      class VIM
        def initialize
        end
      end
    end

    @vm_folder = double 'vm_folder'
    @vm_folder.stub(:traverse).and_return(double 'folder')
    @vim = RbVmomi::VIM.new()
    @vim.stub_chain(:dc, :vmFolder).and_return(@vm_folder)
    VMonkey.stub(:connect).and_return(@vim)
  end


  describe '#folder' do
    FOLDER_PATH = '/path/to/folder'

    subject { @vm_folder }
    it { should receive(:traverse).with( FOLDER_PATH, RbVmomi::VIM::Folder ) }
    after(:each) { VMonkey.connect.folder FOLDER_PATH }
  end

  describe '#vm' do
    VM_PATH = '/path/to/VM'

    subject { @vm_folder }
    it { should receive(:traverse).with( VM_PATH, RbVmomi::VIM::VirtualMachine ) }
    after(:each) { VMonkey.connect.vm VM_PATH }
  end

  describe '#vapp' do
    VAPP_PATH = '/path/to/VApp'

    subject { @vm_folder }
    it { should receive(:traverse).with( VAPP_PATH, RbVmomi::VIM::VirtualApp ) }
    after(:each) { VMonkey.connect.vapp VAPP_PATH }
  end

  describe '#get' do
    GET_PATH = '/path/to/somthing'

    subject { @vm_folder }
    it { should receive(:traverse).with( GET_PATH ) }
    after(:each) { VMonkey.connect.get GET_PATH }
  end

end