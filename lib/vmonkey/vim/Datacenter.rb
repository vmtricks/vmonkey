class RbVmomi::VIM::Datacenter

  ## modified from knife-vsphere / base_vsphere_command.rb
  def find_pool(pool_path = '/')
    parent = self.hostFolder

    pool_path.split('/').each do |path_element|
      next if path_element == ''

      case parent
      when RbVmomi::VIM::Folder
        chilln = parent.childEntity
      when RbVmomi::VIM::ClusterComputeResource, RbVmomi::VIM::ComputeResource
        chilln = parent.resourcePool.resourcePool
      when RbVmomi::VIM::ResourcePool
        chilln = parent.resourcePool
      else
        parent = nil
        break
      end

      parent = chilln.find { |f| f.name == path_element }
    end

    unless parent.is_a?(RbVmomi::VIM::ResourcePool)
      if parent.respond_to?(:resourcePool)
        parent = parent.resourcePool
      end
    end

    parent
  end

end