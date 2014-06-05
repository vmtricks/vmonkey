require_relative 'spec_helper'

describe VMonkey do
  describe '#connect' do
    before(:each) do
      @dc = double
      @cluster = double
      @dc.stub(:find_compute_resource).and_return @cluster
      @vim = double
      @vim.stub(:dc).and_return @dc
      @vim.stub :dc=
      @vim.stub :cluster=
      @vim.stub :opts=
      @vim.stub_chain(:serviceInstance, :find_datacenter).and_return @dc
      RbVmomi::VIM.stub(:connect).and_return @vim
    end

    context 'with options' do
      CONNECT_OPTS = {
          host: 'host',
          user: 'user',
          password: 'password',
          insecure: true,
          ssl: true,
          datacenter: 'datacenter',
          cluster: 'cluster'
          }

      before(:each) { @vim.stub(:opts).and_return CONNECT_OPTS }

      after(:each) { VMonkey.connect(CONNECT_OPTS) }

      subject { RbVmomi::VIM }
      it { should receive(:connect).with(hash_including host: 'host') }
      it { should receive(:connect).with(hash_including user: 'user') }
      it { should receive(:connect).with(hash_including password: 'password') }
      it { should receive(:connect).with(hash_including insecure: true) }
      it { should receive(:connect).with(hash_including ssl: true) }

      context 'returned vim' do
        subject { @vim }
        it { should receive(:dc=).with(@dc) }
      end
    end

    context 'without options' do
      VMONKEY_YML = {
          host: 'yml_host',
          user: 'yml_user',
          password: 'yml_password',
          insecure: true,
          ssl: true,
          datacenter: 'yml_datacenter',
          cluster: 'yml_cluster'
          }

      before(:each) do
        YAML.stub(:load_file).and_return(VMONKEY_YML)
        @vim.stub(:opts).and_return CONNECT_OPTS
      end

      after(:each) { VMonkey.connect }

      subject { RbVmomi::VIM }
      it { should receive(:connect).with(hash_including host: 'yml_host') }
      it { should receive(:connect).with(hash_including user: 'yml_user') }
      it { should receive(:connect).with(hash_including password: 'yml_password') }
      it { should receive(:connect).with(hash_including insecure: true) }
      it { should receive(:connect).with(hash_including ssl: true) }

      context 'returned vim' do
        subject { @vim }
        it { should receive(:dc=).with(@dc) }
      end
    end

  end
end