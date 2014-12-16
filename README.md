# VMonkey

VMonkey is a cheeky little feller who wants so very badly to make interacting with vSphere more enjoyable.  Let VMonkey fetch your VMs, clone your templates, set your properties, and more.  VMonkey tinkers around in the uglier parts of the vSphere API so you don't have to.  Enjoy!

## Installation

Add this line to your application's Gemfile:

    gem 'vmonkey'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vmonkey

## Usage

### $HOME/.vmonkey (optional)

```yml
host: vsphere.host.name
user: vsphere_user
password: monkey!
insecure: false #or true
ssl: true #or false
datacenter: your_dc_name
cluster: your_cluster_or_compute_resource_name
```

### initial connection

```ruby
# use connect opts from $HOME/.vmonkey
monkey = VMonkey.connect
```

or

```ruby
# use your own connect opts
monkey = VMonkey.connect opts_hash
```

### what is VMonkey

VMonkey.connect simply returns an instance of RbVmomi::VIM with added utility methods.  The utility methods operate within the datacenter and cluster specified by the connection options.


### VMonkey finds stuff

```ruby
monkey.folder  '/path/to/my/folder' # returns a Folder or nil
monkey.folder! '/path/to/my/folder' # returns a Folder or raises an error

monkey.vm  '/path/to/my/vm' # returns a VirtualMachine or nil
monkey.vm! '/path/to/my/vm' # returns a VirtualMachine or raises an error

monkey.vapp  '/path/to/my/vapp' # returns a VirtualApp or nil
monkey.vapp! '/path/to/my/vapp' # returns a VirtualApp or raises an error
```

### VMonkey puts his glitter on VirtualMachine instances
    
```ruby
vm.annotation
vm.annotation = 'VMonkey is hot'

vm.move_to  '/path/to/some_folder/clone_name' # moves the VM or raises if the destination exists
vm.move_to! '/path/to/some_folder/clone_name' # moves the VM, overwriting the destination VM if necessary

vm.clone_to '/path/to/some_folder/clone_name' # clones the VM to a Folder
vm.clone_to '/path/to/some_vapp/clone_name'   # clones the VM to a VirtualApp

vm.property  :foo        # returns the value of a vApp property, or nil
vm.property! :foo        # returns the value of a vApp property, or raises an error
vm.property  :foo, 'bar' # set the value of a vApp property

vm.port_ready? 22   # true if the VM is listening a TCP port
vm.wait_for_port 22 # blocks until the port_ready? is true

vm.start   # power on if needed
vm.stop    # guest shutdown and power off
vm.destroy # deletes the VM from the inventory, no need to power off first
```

### VMonkey gives some love to other types, too

```ruby
datacenter.find_pool                    # returns the default datacenter ResourcePool
datacenter.find_pool '/path/to/cluster' # returns the cluster's default ResourcePool
datacenter.find_pool '/path/to/vapp'    # returns the vApp, since it's already a ResourcePool

vapp.find_vm  'vm_name' # returns a VM of the given name, or nil
```

### VMonkey earns his keep

Before:

```ruby
config = [annotation: 'This makes VMonkey sad.']
spec = RbVmomi::VIM.VirtualMachineConfigSpec(config)
vm.ReconfigVM_Task(spec: spec).wait_for_completion
```

After:

```ruby
vm.annotation = 'VMonkey is so easy!'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vmonkey )
2. Setup your test environment (`bundle exec rake spec` and follow the test setup instructions)
3. Hack
4. Pull request ( be sure to include updated specs )
