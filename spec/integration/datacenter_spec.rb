require_relative 'spec_helper'

describe RbVmomi::VIM::Datacenter do
  before :all do
    @monkey = VMonkey.connect
    @cluster_path = "/#{@monkey.opts[:cluster]}"
  end

  describe '#find_pool' do
    context 'with no params' do
      subject { @pool ||= VMonkey.connect.dc.find_pool }

      it { should_not be_nil }
      its(:name) { should == 'host' }
    end

    context 'with cluster path' do
      subject { @pool ||= VMonkey.connect.dc.find_pool @cluster_path }

      it { should_not be_nil }
      its(:name) { should == 'Resources' }
    end

    context 'with vApp path' do
      subject { @pool ||= VMonkey.connect.dc.find_pool VM_SPEC_OPTS[:vapp_pool_path] }

      it { should_not be_nil }
      its(:name) { should == VM_SPEC_OPTS[:vapp_pool_path].split('/').last }
    end
  end
end