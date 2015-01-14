require_relative 'spec_helper'

describe RbVmomi::VIM::Folder do
  before :all do
    @monkey ||= VMonkey.connect
    @folder ||= @monkey.folder VM_SPEC_OPTS[:working_folder]
  end

  # describe '#vm_pool' do
  #   subject { @folder.vm_pool }
  #   it { should_not be_nil }
  # end

  describe '#folder!' do
    it 'should raise an error when the folder doesn\'t exist' do
      expect { @folder.folder! 'not_here' }.to raise_error
    end
  end

  describe '#folder' do
    before :all do
      @folder.mk_folder 'vmonkeytmp/tmp2'
    end

    it 'should find a folder by a single path element' do
      expect(@folder.folder('vmonkeytmp')).to_not be_nil
      expect(@folder.folder('vmonkeytmp').name).to eq('vmonkeytmp')
    end

    it 'should find a folder by a nested path' do
      expect(@folder.folder('vmonkeytmp/tmp2')).to_not be_nil
      expect(@folder.folder('vmonkeytmp/tmp2').name).to eq('tmp2')
    end

    after :all do
      @folder.folder('vmonkeytmp').destroy
    end
  end

  describe '#mk_folder' do
    before :all do
      @sub = @folder.mk_folder 'vmonkeytmp/tmp3'
    end

    it 'should create nested folders' do
      expect(@folder.folder!('vmonkeytmp/tmp3').name).to eq('tmp3')
      expect(@folder.folder!('vmonkeytmp/tmp3').parent.parent.name).to eq(@folder.name)
      expect(@sub.name).to eq('tmp3')
    end

    after :all do
      @folder.folder!('vmonkeytmp').destroy
    end
  end
end