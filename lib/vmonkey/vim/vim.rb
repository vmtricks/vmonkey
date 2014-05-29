require 'yaml'

module RbVmomi
  class VIM

    def self.monkey_connect(opts = nil)
      opts ||= self.read_yml_opts
      vim = self.connect(opts)
      vim.dc = vim.serviceInstance.find_datacenter(opts[:datacenter]) or raise "Datacenter not found [#{opts[:datacenter]}]"

      vim
    end

    attr_accessor :dc

    def folder(path)
      dc.vmFolder.traverse path, RbVmomi::VIM::Folder
    end

    def vm(path)
      dc.vmFolder.traverse path, RbVmomi::VIM::VirtualMachine
    end

    private

    def self.read_yml_opts
      yml_path = File.expand_path( ENV['VMONKEY_YML'] || File.join(ENV['HOME'], '.vmonkey') )
      YAML::load_file(yml_path).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

  end
end
