require 'rbvmomi'
require_relative 'vmonkey/version'
require_relative 'vmonkey/vim/vim'

monkey_vim = File.join(File.dirname(__FILE__), 'vmonkey', 'vim')
RbVmomi::VIM.add_extension_dir monkey_vim

module VMonkey
  def self.connect(opts = nil)
    RbVmomi::VIM.monkey_connect(opts)
  end
end