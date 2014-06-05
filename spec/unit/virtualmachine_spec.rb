require_relative 'spec_helper'

describe 'RbVmomi::VirtualMachine' do
  before(:each) do
    class RbVmomi::VIM::VirtualMachine
      def initialize
      end
    end

    @vim = RbVmomi::VIM.new()
    VMonkey.stub(:connect).and_return(@vim)
    @vm = RbVmomi::VIM::VirtualMachine.new()
    @vm.stub :Destroy_Task
    @vm.stub_chain(:runtime, :powerState).and_return 'poweredOff'
    @vm.stub_chain(:PowerOffVM_Task, :wait_for_completion)

    @vim.stub(:vm).and_return @vm
  end

  context 'when powered off' do
    describe '#destroy' do
      subject { @vm }
      it { should_not receive(:PowerOffVM_Task) }
      it { should receive(:Destroy_Task) }
      after(:each) { @vm.destroy }
    end
  end

  context 'when powered on' do
    before(:each) do
      @vm.stub_chain(:runtime, :powerState).and_return 'poweredOn'
    end

    describe '#destroy' do
      subject { @vm }
      it { should receive(:PowerOffVM_Task) }
      it { should receive(:Destroy_Task) }
      after(:each) { @vm.destroy }
    end
  end

end