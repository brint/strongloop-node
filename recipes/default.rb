# Load attributes from Encrypted DataBag if any
begin
  databag = Chef::EncryptedDataBagItem.load(node["strongloop"]["databag_name"], "secrets")
rescue
  Chef::Log.debug("No databag found. Using attributes.")
end

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
begin
  plain_pass = databag['strongloop']['password']
rescue
  if node['strongloop']['password'].nil?
    plain_pass = secure_password
  else
    plain_pass = node['strongloop']['password']
  end
end

# Create hash from password
if node['strongloop']['shadow_hash'].nil?
  salt = rand(36**8).to_s(36)
  shadow_hash = plain_pass.crypt("$6$" + salt)
  node.set_unless['strongloop']['shadow_hash'] = shadow_hash
end

chef_gem "ruby-shadow"

user node['strongloop']['username'] do
  supports :manage_home => true
  comment "StrongLoop User"
  shell "/bin/bash"
  home "/home/#{node['strongloop']['username']}"
  password node['strongloop']['shadow_hash']
  action :create
end

home_dir = ::File.join("/home", node['strongloop']['username'])

### Setup NodeJS and NPM
node.set[:nodejs][:version] = "0.10.22"
node.set[:nodejs][:checksum] = "157fc58b3f1d109baefac4eb1d32ae747de5e6d55d87d0e9bec8f8dd10679e7e"
node.set[:nodejs][:checksum_linux_x86] = "3823d08199b2c952cd85d1b89ba03d59f2782985ba8d25e040e4cfecdb679aff"
node.set[:nodejs][:checksum_linux_x64] = "ca5bebc56830260581849c1099f00d1958b549fc59acfc0d37b1f01690e7ed6d"

include_recipe "nodejs::install_from_binary"

npm_package "strong-cli"

bash "strongloop_webapp" do
  cwd home_dir
  code "slc example"
end

include_recipe "supervisor"

supervisor_service "strongloop" do
  action :enable
  autostart true
  autorestart true
  user node['strongloop']['username']
  command "slc run sls-sample-app"
  stopsignal "INT"
  stopasgroup true
  killasgroup true
  stopwaitsecs 20
  directory "#{home_dir}"
end
