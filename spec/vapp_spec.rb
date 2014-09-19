require_relative 'spec_helper'
using VMonkey unless RUBY_VERSION.split('.')[0] == '1'

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

    describe '#move_to' do
      it 'should raise a RuntimeError when given a path of an existing vApp' do
        expect { @spec_vapp.move_to @spec_vapp_path }.to raise_error RuntimeError
      end

      it 'should move a vapp to a new name in the same folder' do
        parent = @spec_vapp.parentFolder

        @spec_vapp.move_to "#{@spec_vapp_path}-moved"
        expect(@spec_vapp.name).to eq "#{@spec_vapp_path.basename}-moved"
        expect(@spec_vapp.parentFolder).to eq parent

        @spec_vapp.move_to @spec_vapp_path
        expect(@spec_vapp.name).to eq @spec_vapp_path.basename
        expect(@spec_vapp.parentFolder).to eq parent
      end

      it 'should move a vapp to the same name in a new folder' do
        from_folder = @spec_vapp.parentFolder
        from_name = @spec_vapp.name
        to_path = "#{VM_SPEC_OPTS[:working_folder2]}/#{@spec_vapp_path.basename}"
        to_folder = @monkey.folder VM_SPEC_OPTS[:working_folder2]

        @spec_vapp.move_to to_path
        expect(@spec_vapp.name).to eq from_name
        expect(@spec_vapp.parentFolder).to eq to_folder

        @spec_vapp.move_to @spec_vapp_path
        expect(@spec_vapp.name).to eq from_name
        expect(@spec_vapp.parentFolder).to eq from_folder
      end

      it 'should move a vapp to a new name in a new folder' do
        from_folder = @spec_vapp.parentFolder
        from_name = @spec_vapp.name
        to_name = "#{@spec_vapp_path.basename}-different"
        to_path = "#{VM_SPEC_OPTS[:working_folder2]}/#{to_name}"
        to_folder = @monkey.folder VM_SPEC_OPTS[:working_folder2]

        @spec_vapp.move_to to_path
        expect(@spec_vapp.name).to eq to_name
        expect(@spec_vapp.parentFolder).to eq to_folder

        @spec_vapp.move_to @spec_vapp_path
        expect(@spec_vapp.name).to eq from_name
        expect(@spec_vapp.parentFolder).to eq from_folder
      end
    end

    describe '#move_to!' do
      before(:all) do
        @other_path = "#{@spec_vapp_path}-other"
        @other_vapp = @spec_vapp.clone_to @other_path
      end

      after(:all) do
        other_vapp = @monkey.vapp @other_path
        other_vapp.destroy if other_vapp
      end

      it 'should overwrite a vApp when given a path of an existing VM' do
        @spec_vapp.move_to! @other_path
        expect(@monkey.vapp @other_path).to_not be_nil

        @spec_vapp.move_to @spec_vapp_path
        expect(@monkey.vapp @other_path).to be_nil
      end
    end

    describe '#stop' do
      it 'should return successfully when the vApp is already powered off' do
        expect { @spec_vapp.stop }.to_not raise_error
      end
    end

    describe '#port_ready?' do
      it 'should be false when the vApp is powered off' do
        expect( @spec_vapp.port_ready? 22 ).to be_falsey
      end
    end

    context 'that has had #start called' do
      before(:all) { @spec_vapp.start }
      after(:all) { @spec_vapp.stop }

      context 'immediately following start' do
        describe '#port_ready?' do
          it 'should be false' do
            expect(@spec_vapp.port_ready? 22).to be_falsey
          end
        end
      end

      context 'following wait_for_port' do
        before(:all) { @spec_vapp.wait_for_port 22 }

        describe '#port_ready?' do
          it 'should be true' do
            expect(@spec_vapp.port_ready? 22).to be_truthy
          end
        end
      end

    end

  end
end