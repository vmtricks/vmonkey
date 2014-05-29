require_relative 'spec_helper'

describe 'RbVmomi::VIM' do
  describe '#folder' do
    FOLDER_PATH = '/path/to/folder'

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

    after(:each) { VMonkey.connect.folder FOLDER_PATH }

    subject { @vm_folder }
    it { should receive(:traverse).with( FOLDER_PATH, RbVmomi::VIM::Folder ) }

  end

end