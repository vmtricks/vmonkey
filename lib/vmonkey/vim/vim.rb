require 'yaml'

module RbVmomi
  class VIM

    attr_accessor :dc
    attr_accessor :cluster
    attr_accessor :opts

    def self.monkey_connect(opts = nil)
      opts ||= self.read_yml_opts
      vim = self.connect(opts)
      vim.opts = opts
      vim.dc = vim.serviceInstance.find_datacenter(vim.opts[:datacenter]) or raise "Datacenter not found [#{vim.opts[:datacenter]}]"
      vim.cluster = vim.dc.find_compute_resource(vim.opts[:cluster]) or raise "Cluster not found [#{vim.opts[:cluster]}]"

      vim
    end

    def folder(path)
      dc.vmFolder.traverse path, RbVmomi::VIM::Folder
    end

    def folder!(path)
      folder(path) || raise("Folder not found. [#{path}]")
    end

    def vm(path)
      dc.vmFolder.traverse path, RbVmomi::VIM::VirtualMachine
    end

    def vm!(path)
      vm(path) || raise("VirtualMachine not found. [#{path}]")
    end

    def vm_by_uuid(uuid)
      dc.vmFolder.findByUuid uuid, RbVmomi::VIM::VirtualMachine, dc
    end

    def vm_by_uuid!(uuid)
      vm_by_uuid(uuid) || raise("VirtualMachine not found. [#{uuid}]")
    end

    def vm_by_instance_uuid(uuid)
      dc.vmFolder.findByInstanceUuid uuid
    end

    def vm_by_instance_uuid!(uuid)
      vm_by_instance_uuid(uuid) || raise("VirtualMachine not found. [#{uuid}]")
    end

    def vapp(path)
      dc.vmFolder.traverse path, RbVmomi::VIM::VirtualApp
    end

    def vapp!(path)
      vapp(path) || raise("VirtualApp not found. [#{path}]")
    end

    def get(path)
      dc.vmFolder.traverse path
    end

    def customization_spec(spec_name)
      return nil if spec_name.nil?
      serviceContent.customizationSpecManager.GetCustomizationSpec(name: spec_name).spec
    rescue
      nil
    end

    private

    def self.read_yml_opts
      yml_path = File.expand_path( ENV['VMONKEY_YML'] || File.join(ENV['HOME'], '.vmonkey') )
      YAML::load_file(yml_path).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

  end
end
