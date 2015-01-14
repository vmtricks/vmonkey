class RbVmomi::VIM::Folder
  def vm_pool
    monkey.cluster.resourcePool
  end

  def vm_folder
    self
  end

  def findByInstanceUuid uuid, type=RbVmomi::VIM::VirtualMachine, dc=nil
    propSpecs = {
      :entity => self, :uuid => uuid, :instanceUuid => true,
      :vmSearch => type == RbVmomi::VIM::VirtualMachine
    }
    propSpecs[:datacenter] = dc if dc
    x = _connection.searchIndex.FindByUuid(propSpecs)
    x if x.is_a? type
  end

  def templates
    self.childEntity.grep(RbVmomi::VIM::VirtualMachine).select { |v| v.config && v.config.template }
  end

  def vms
    self.childEntity.grep(RbVmomi::VIM::VirtualMachine).select { |v| v.config.nil? || (v.config && !v.config.template) }
  end

  def folder(path)
    self.traverse path, RbVmomi::VIM::Folder
  end

  def folder!(path)
    folder(path) || raise("Folder not found. [#{path}]")
  end

  def mk_folder(path)
    self.traverse path, RbVmomi::VIM::Folder, true
  end

  def destroy
    self.Destroy_Task.wait_for_completion
  end

end