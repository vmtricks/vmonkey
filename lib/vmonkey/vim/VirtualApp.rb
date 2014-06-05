class RbVmomi::VIM::VirtualApp
  def vm_pool
    self
  end

  def vm_folder
    parentVApp.nil? ? parentFolder : self.parentVApp.vm_folder
  end

  def find_vm(vm_name)
    vm.find { |vm| vm.name == vm_name }
  end
end



