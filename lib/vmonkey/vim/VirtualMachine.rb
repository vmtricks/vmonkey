class RbVmomi::VIM::VirtualMachine

  def destroy
    self.PowerOffVM_Task.wait_for_completion unless runtime.powerState == 'poweredOff'
    self.Destroy_Task
  end

  def clone_to(path, opts = {})
    dest = monkey.get(path.parent)
    unless dest.is_a? RbVmomi::VIM::Folder or dest.is_a? RbVmomi::VIM::VirtualApp
      raise "Cannot clone_to [#{dest.pretty_path}] - destination must specify a Folder or VirtualApp"
    end

    params = clone_params(path.basename, dest, opts)

    self.CloneVM_Task(params).wait_for_completion
  end

  def clone_params(vm_name, dest, opts)
    {
      name: vm_name,
      folder: dest.vm_folder,
      spec: clone_spec(dest, opts)
    }
  end

  def clone_spec(dest, opts)
    opts[:config] ||= {}

    clone_spec = RbVmomi::VIM.VirtualMachineCloneSpec(
      location: RbVmomi::VIM.VirtualMachineRelocateSpec(pool: dest.vm_pool),
      powerOn: false,
      template: false
    )

    clone_spec.config = RbVmomi::VIM.VirtualMachineConfigSpec(deviceChange: Array.new)

    clone_spec.customization = monkey.customization_spec(opts[:customization_spec])
    clone_spec.config.annotation = opts[:config][:annotation]
    clone_spec.config.numCPUs = opts[:config][:num_cpus]
    clone_spec.config.memoryMB = opts[:config][:memory_mb]

    clone_spec
  end

end

