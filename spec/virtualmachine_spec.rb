require_relative 'spec_helper'
using VMonkey unless RUBY_VERSION.split('.')[0] == '1'

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
              memory_mb: 1024,
              files: { :vmPathName => "#{VM_SPEC_OPTS[:datastore]} vmonkey-test" }
            })
      end

      it { expect(subject[:spec].customization).to_not be_nil }
      it { expect(subject[:spec].config.annotation).to eq 'an annotation' }
      it { expect(subject[:spec].config.numCPUs).to eq 3 }
      it { expect(subject[:spec].config.memoryMB).to eq 1024 }
      it { expect(subject[:spec].config.files[:vmPathName]). to eq "#{VM_SPEC_OPTS[:datastore]} vmonkey-test" }
      it { expect(subject[:spec].config.deviceChange.length).to be 0}
    end

    context 'with datastore change' do
      subject do
        @params ||=
          @template._clone_params(
            @vm_path.basename,
            @monkey.get(@vm_path.parent),
            datastore: @monkey.datastore(VM_SPEC_OPTS[:datastore]))
      end

      it { expect(subject[:spec][:location].datastore).to_not be_nil }
    end

    context 'with deviceChange' do
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
            },
            deviceChange: [
              {
                :operation => :add,
                :device => RbVmomi::VIM.VirtualE1000(
                  :key => 0,
                  :deviceInfo => {
                    :label => 'VM network',
                    :summary => 'VM network'
                  },
                  :backing => RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(
                    :deviceName => 'VM network'
                  ),
                  :addressType => 'automatic'
                )
              }
              ])
      end

      it { expect(subject[:spec].config.deviceChange[0][:operation]).to be :add}
    end
  end

  context 'with a cloned VM' do
    before(:all) { @spec_vm = @template.clone_to @vm_path }
    after(:all)  { @spec_vm.destroy }

    describe '#clone_to' do
      context 'to a Folder' do
        subject { @monkey.vm @vm_path }
        it { should_not be_nil }
      end
    end

    describe '#clone_to!' do
      before(:all) do
        @other_path = "#{@vm_path}-other"
      end

      after(:all) do
        other_vm = @monkey.vm @other_path
        other_vm.destroy if other_vm
      end

      it 'should overwrite a VM when given a path of an existing VM' do
        expect{
          @other_vm = @spec_vm.clone_to! @other_path
          @other_vm = @spec_vm.clone_to! @other_path
        }.to_not raise_error
      end
    end

    describe '#move_to' do
      it 'should raise a RuntimeError when given a path of an existing VM' do
        expect { @spec_vm.move_to @vm_path }.to raise_error RuntimeError
      end

      it 'should move a vm to a new name in the same folder' do
        parent = @spec_vm.parent

        @spec_vm.move_to "#{@vm_path}-moved"
        expect(@spec_vm.name).to eq "#{@vm_path.basename}-moved"
        expect(@spec_vm.parent).to eq parent

        @spec_vm.move_to @vm_path
        expect(@spec_vm.name).to eq @vm_path.basename
        expect(@spec_vm.parent).to eq parent
      end

      it 'should move a vm to the same name in a new folder' do
        from_folder = @spec_vm.parent
        from_name = @spec_vm.name
        to_path = "#{VM_SPEC_OPTS[:working_folder2]}/#{@vm_path.basename}"
        to_folder = @monkey.folder VM_SPEC_OPTS[:working_folder2]

        @spec_vm.move_to to_path
        expect(@spec_vm.name).to eq from_name
        expect(@spec_vm.parent).to eq to_folder

        @spec_vm.move_to @vm_path
        expect(@spec_vm.name).to eq from_name
        expect(@spec_vm.parent).to eq from_folder
      end

      it 'should move a vm to a new name in a new folder' do
        from_folder = @spec_vm.parent
        from_name = @spec_vm.name
        to_name = "#{@vm_path.basename}-different"
        to_path = "#{VM_SPEC_OPTS[:working_folder2]}/#{to_name}"
        to_folder = @monkey.folder VM_SPEC_OPTS[:working_folder2]

        @spec_vm.move_to to_path
        expect(@spec_vm.name).to eq to_name
        expect(@spec_vm.parent).to eq to_folder

        @spec_vm.move_to @vm_path
        expect(@spec_vm.name).to eq from_name
        expect(@spec_vm.parent).to eq from_folder
      end
    end

    describe '#move_to!' do
      before(:all) do
        @other_path = "#{@vm_path}-other"
        @other_vm = @spec_vm.clone_to @other_path
      end

      after(:all) do
        other_vm = @monkey.vm @other_path
        other_vm.destroy if other_vm
      end

      it 'should overwrite a VM when given a path of an existing VM' do
        @spec_vm.move_to! @other_path
        expect(@monkey.vm @other_path).to_not be_nil

        @spec_vm.move_to @vm_path
        expect(@monkey.vm @other_path).to be_nil
      end
    end

    describe '#stop' do
      it 'should return successfully when the VM is already powered off' do
        expect { @spec_vm.stop }.to_not raise_error
      end
    end

    describe '#port_ready?' do
      it 'should be false when the VM is powered off' do
        expect( @spec_vm.port_ready? 22 ).to be_falsey
      end
    end

    context 'that has had #start called' do
      before(:all) { @spec_vm.start }

      context 'immediately following start' do
        describe '#ready?' do
          it 'should be false' do
            expect(@spec_vm.ready?).to be_falsey
          end
        end

        describe '#port_ready?' do
          it 'should be false' do
            expect(@spec_vm.port_ready? 22).to be_falsey
          end
        end
      end

      context 'following wait_for_port' do
        before(:all) { @spec_vm.wait_for_port 22 }

        describe '#ready?' do
          it 'should be true' do
            expect(@spec_vm.ready?).to be_truthy
          end
        end

        describe '#port_ready?' do
          it 'should be true' do
            expect(@spec_vm.port_ready? 22).to be_truthy
          end
        end
      end

      after(:all) { @spec_vm.stop }
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