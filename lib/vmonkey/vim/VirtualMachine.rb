class RbVmomi::VIM::VirtualMachine

  def destroy
    self.PowerOffVM_Task.wait_for_completion unless runtime.powerState == 'poweredOff'
    self.Destroy_Task.wait_for_completion
  end

  def clone_to(path, opts = {})
    dest = monkey.get(path.parent)
    unless dest.is_a? RbVmomi::VIM::Folder or dest.is_a? RbVmomi::VIM::VirtualApp
      raise "Cannot clone_to [#{path.parent}] - destination must specify a Folder or VirtualApp"
    end

    params = _clone_params(path.basename, dest, opts)

    self.CloneVM_Task(params).wait_for_completion
  end

  def annotation
    config.annotation
  end

  def annotation=(value)
    ReconfigVM_Task(spec: RbVmomi::VIM.VirtualMachineConfigSpec(annotation: value)).wait_for_completion
  end

  def property(*args)
    case args.size
    when 1
      read_property(*args)
    when 2
      set_property(*args)
    else
      raise ArgumentError.new("wrong number of arguments (#{args.size} for 1 or 2)")
    end
  end

  def property!(name)
    read_property(name) || raise("vApp Property not found. [#{name}]")
  end

  def move_to(path)
    monkey.vm(path) && raise("VirtualMachine already exists. [#{path}]")
    rename = name != path.basename

    to_folder = monkey.folder! path.parent
    reparent = parent != to_folder

    if reparent
      Rename_Task(newName: "#{path.basename}-tmp").wait_for_completion if rename
      to_folder.MoveIntoFolder_Task(list: [self]).wait_for_completion
      Rename_Task(newName: path.basename).wait_for_completion if rename
    else
      Rename_Task(newName: path.basename).wait_for_completion
    end
  end

  unless self.method_defined? :guest_ip
    ## backported from rbvmomi 1.8 for rbvmomi 1.5 support
    def guest_ip
      g = self.guest
      if g.ipAddress && (g.toolsStatus == "toolsOk" || g.toolsStatus == "toolsOld")
        g.ipAddress
      else
        nil
      end
    end
  end

  def move_to!(path)
    dest_vm = monkey.vm(path)
    dest_vm.destroy if dest_vm

    move_to(path)
  end

  def port_ready?(port)
    ip = guest_ip or return false
    tcp_socket = TCPSocket.new(ip, port)
    readable = IO.select([tcp_socket], nil, nil, 5)
    if readable
      true
    else
      false
    end
  rescue Errno::ETIMEDOUT, Errno::EPERM, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
    false
  ensure
    tcp_socket && tcp_socket.close
  end

  def wait_for(max=300, interval=2, &block)
    elapsed = 0
    start = Time.now

    until (result = yield) || (elapsed > max)
      sleep interval
      elapsed = Time.now - start
    end

    unless result
      raise Errors::TimeoutError.new "Waited #{max} seconds, giving up"
    end

    true
  end

  def wait_for_port(port)
    wait_for { port_ready?(port) }
  end

  def stop
    return if runtime.powerState == 'poweredOff'
    ShutdownGuest()
    sleep 2 until runtime.powerState == 'poweredOff'
  rescue
    PowerOffVM_Task().wait_for_completion unless runtime.powerState == 'poweredOff'
  end

  def start
    PowerOnVM_Task().wait_for_completion unless runtime.powerState == 'poweredOn'
  end

  def started?
    runtime.powerState == 'poweredOn'
  end

  def ready?
    ! guest_ip.nil?
  end

  def find_property(name)
    config.vAppConfig.property.find { |p| p.props[:id] == name.to_s  }
  end

  def read_property(name)
    p = find_property(name)
    p.nil? ? nil : p[:value]
  end

  def set_property(name, value)
    if config.vAppConfig && config.vAppConfig.property
      existing_property = find_property(name)
    end

    if existing_property
      operation = 'edit'
      property_key = existing_property.props[:key]
    else
      operation = 'add'
      property_key = name.object_id
    end

    vm_config_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
      vAppConfig: RbVmomi::VIM.VmConfigSpec(
        property: [
          RbVmomi::VIM.VAppPropertySpec(
            operation: operation,
            info: {
              key: property_key,
              id: name.to_s,
              type: 'string',
              userConfigurable: true,
              value: value
              })]))

    if config.vAppConfig.nil? || config.vAppConfig.ovfEnvironmentTransport.empty?
      vm_config_spec[:vAppConfig][:ovfEnvironmentTransport] = ['com.vmware.guestInfo']
    end

    ReconfigVM_Task( spec: vm_config_spec ).wait_for_completion
  end

  def _clone_params(vm_name, dest, opts)
    {
      name: vm_name,
      folder: dest.vm_folder,
      spec: _clone_spec(dest, opts)
    }
  end

  def _clone_spec(dest, opts)
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

