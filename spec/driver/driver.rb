require_relative '../../lib/vmonkey'

monkey = VMonkey.connect

# puts monkey.folder('/Templates').name.inspect
# puts monkey.vm('/Templates/c64.medium').name.inspect
# puts monkey.vapp('/RallyVM/vapp_ci-lastSuccessfulBuild').name.inspect

template = monkey.vm '/Templates/c64.medium'
# puts template.name
# puts template.config.annotation

# puts monkey.dc.name.inspect
# puts monkey.dc.find_pool.name
# puts monkey.dc.find_pool('/Engineering').name
# puts monkey.dc.find_pool('/Engineering/vapp_ci-lastTested').name

# puts monkey.get('/Template CI/monkey_box'.parent).pretty_path
# puts monkey.get('/RallyVM_CI/vapp_ci-lastTested/monkey_box'.parent).pretty_path

# box = monkey.vm '/Template CI/monkey_driver'
# box.destroy unless box.nil?

# box = template.clone_to '/Template CI/monkey_driver'
# box.destroy

box = template.clone_to '/Template CI/monkey_vapp/monkey_driver'
# box.destroy

# vapp = monkey.vapp 'Template CI/monkey_vapp'
# box = template.clone_to '/RallyVM/vapp_ci-lastSuccessfulBuild/some_box'

exit

puts box.name


puts box.config.annotation
box.config.annotation 'Hello world'

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
