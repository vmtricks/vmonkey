using VMonkey

class RbVmomi::VIM::VirtualApp

  def destroy
    self.PowerOffVApp_Task( force: true ).wait_for_completion unless vapp_state? 'stopped'
    self.Destroy_Task( force: true ).wait_for_completion
  end

  def vapp_state?(state)
    summary.vAppState.downcase == state
  end

  def start
    PowerOnVApp_Task().wait_for_completion unless vapp_state? 'started'
  end

  def vm_pool
    self
  end

  def path_with_name
    "#{vm_folder.name}/#{self.name}"
  end

  def vm_folder
    parentVApp.nil? ? parentFolder : self.parentVApp.vm_folder
  end

  def find_vm(vm_name)
    vm.find { |vm| vm.name == vm_name }
  end

  def annotation
    vAppConfig.annotation
  end

  def annotation=(value)
    UpdateVAppConfig(spec: {annotation: value})
  end

  def properties
    vAppConfig.property
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

  def clone_to(path, opts = {})
    dest = opts[:vmFolder] || monkey.get(path.parent)
    unless dest.is_a? RbVmomi::VIM::Folder or dest.is_a? RbVmomi::VIM::VirtualApp
      raise "Cannot clone_to [#{path.parent}] - destination must specify a Folder or VirtualApp"
    end

    if opts[:datastore].nil?
      opts[:datastore] = datastore.first   #take the first datastore on the vApp to be cloned
    end

    params = _clone_params(path.basename, dest, opts)

    self.CloneVApp_Task(params).wait_for_completion
  end

  def find_property(name)
    vAppConfig.property.find { |p| p.props[:id] == name.to_s  }
  end

  def read_property(name)
    p = find_property(name)
    p.nil? ? nil : p[:value]
  end

  def set_property(name, value)
    if vAppConfig.property
      existing_property = find_property(name)
    end

    if existing_property
      operation = 'edit'
      property_key = existing_property.props[:key]
    else
      operation = 'add'
      property_key = name.object_id
    end

    vm_config_spec = RbVmomi::VIM.VAppConfigSpec(
        property: [
          RbVmomi::VIM.VAppPropertySpec(
            operation: operation,
            info: {
              key: property_key,
              id: name.to_s,
              type: 'string',
              userConfigurable: true,
              value: value.to_s
              })])

    UpdateVAppConfig( spec: vm_config_spec )
  end

  def _clone_params(vapp_name, dest, opts)
    {
      name: vapp_name,
      target: monkey.cluster.resourcePool,
      spec: RbVmomi::VIM.VAppCloneSpec(
        location: opts[:datastore],
        vmFolder: dest
        )
    }
  end

end



