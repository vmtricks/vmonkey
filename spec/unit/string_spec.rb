require_relative 'spec_helper'

describe String do
  describe '#parent' do
    it 'calculates parent path correctly' do
      expect(''.parent).to eq '/'
      expect('/'.parent).to eq '/'
      expect('foo'.parent).to eq '/'
      expect('foo/'.parent).to eq '/'
      expect('foo/bar'.parent).to eq 'foo'
      expect('/foo/bar'.parent).to eq '/foo'
    end
  end
end