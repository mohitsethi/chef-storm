include_recipe "storm::dependencies"
include_recipe "partial_search"

# Get list of zookeeper hosts
node.override['storm']['zookeeper']['hosts'] = search(:node,
                                                      "chef_environment:#{node.chef_environment} AND role:#{node['storm']['storm_zookeeper_role']}",
                                                      :filter_result => {'ipaddress' => ['ipaddress']})

node.override['storm']['nimbus']['host'] = search(:node,
                                                  "chef_environment:#{node.chef_environment} AND role:#{node['storm']['storm_nimbus_role']}",
                                                  :filter_result => {'ipaddress' => ['ipaddress']}).first


if node['storm']['zookeeper']['hosts'].nil?
  Chef::Application.fatal!('No Zookeeper nodes found')
end

if node['storm']['nimbus']['host'].nil?
  Chef::Application.fatal!('No Nimbus node found')
end

storm_remote_name = "#{node['storm']['download_url']}#{node['storm']['download_dir']}"

remote_file "#{Chef::Config[:file_cache_path]}/apache-storm-#{node[:storm][:version]}.tar.gz" do
  # source "#{node['storm']['download_url']}/apache-storm-#{node[:storm][:version]}/apache-storm-#{node[:storm][:version]}.tar.gz"
  source storm_remote_name
  action :create_if_missing
end

directory node['storm']['root_dir'] do
  user "#{node[:storm][:user]}"
  mode 00755
  recursive true
  action :create
  not_if { ::File.directory?("#{node[:storm][:root_dir]}") }
end

execute "extract" do
  cwd     node['storm']['root_dir']
  command "tar -xzvf #{Chef::Config[:file_cache_path]}/apache-storm-#{node[:storm][:version]}.tar.gz"
  not_if { ::File.directory?("#{node[:storm][:root_dir]}/apache-storm-#{node[:storm][:version]}") }
end

directory node['storm']['data_dir'] do
  user "#{node[:storm][:user]}"
  mode 00755
  recursive true
  action :create
  not_if { ::File.directory?("#{node[:storm][:data_dir]}") }
end

template "setup_storm_config" do
  path "#{node[:storm][:root_dir]}/apache-storm-#{node[:storm][:version]}/conf/storm.yaml"
  source "storm.yaml.erb"
  owner node[:storm][:user]
  group node[:storm][:group]
  mode 0744
end

template "/tmp/setup_self_in_hosts.sh" do
  source "conf_self_in_hosts.sh"
  mode 0755
end

execute "setup hosts file" do
  command "sh /tmp/setup_self_in_hosts.sh"
end
