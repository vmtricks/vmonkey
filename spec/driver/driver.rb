require_relative '../../lib/vmonkey'

monkey = VMonkey.connect

puts monkey.folder('/Templates').name.inspect
puts monkey.vm('/Templates/c64.medium').name.inspect
puts monkey.template('/Templates/c64.medium').name.inspect

## specializations of #get
monkey.folder '/path/to/a/folder'
monkey.vm '/path/to/a/vm'
monkey.template '/path/to/a/vm_template'
monkey.vapp '/path/to/a/vapp'

template = monkey.template '/Templates/c64.medium'
puts template.name
puts template.path
puts template.folder.name
puts template.folder.path
puts template.template
puts template.annotation

box = template.clone '/Template CI/monkey_driver'
puts box.name
puts box.path
puts box.folder.name
puts box.folder.path

puts box.annotation
box.annotation 'Hello world'

box.property :boot_for_test, 'true'
puts box.property :boot_for_test

box.start wait: 22
puts box.started?
box.stop # guest shutdown
box.halt # power off

box.move 'new_name'
puts box.name
puts box.path
puts box.folder.name
puts box.folder.path

box.move '/some/other/place/new_name'
puts box.name
puts box.path
puts box.folder.name
puts box.folder.path

box.delete

box.property foo: 'bar', baz: 'boz'

box.property :foo, 'bar'
box.property :foo

box.template true

# box = template.clone do
#   property boot_for_test: true
#   dest '/my/project/box'
#   num_cpus 2
#   mem_mb 1024
#   cust_spec 'bld-cust'
#   datastore 'my-datastore'
#   start true
#   wait_for_port 22
# end

# box.configure do
#   properties {
#     foo: bar
#   }
#   annotation "sdfsdfsdf"
# end


## vm stuff
# find a vm
# clone a vm
# annotate a vm
# set/get properties
# move/rename a vm (force: true)
# delete a vm
# start a vm
# stop a vm
# templatize a vm

## vapp stuff
# create vapp
# find a vapp
# clone a vapp
# annotate a vapp
# set/get properties
# move/rename a vapp (force: true)
# delete a vapp
# start a vapp
# stop a vapp
# clone a vm into vapp
# move a vm into vapp
# delete a vm from a vapp
