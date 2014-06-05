class RbVmomi::VIM::Folder
  def vm_pool
    monkey.cluster.resourcePool
  end

  def vm_folder
    self
  end
end