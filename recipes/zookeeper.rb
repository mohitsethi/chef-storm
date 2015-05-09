package 'java-1.7.0-openjdk-devel'
package 'bison'
package 'flex'
package 'gcc'
package 'gcc-c++'
package 'kernel-devel'
package 'make'
package 'm4'
package 'patch'

remote_file "#{Chef::Config[:file_cache_path]}/zookeeper-#{node[:zookeeper][:version]}.tar.gz" do
  source "#{node[:zookeeper][:download_url]}/zookeeper-#{node[:zookeeper][:version]}/zookeeper-#{node[:zookeeper][:version]}.tar.gz"
  mode   0655
end

directory "#{node[:zookeeper][:root_dir]}" do
  user "#{node[:zookeeper][:user]}"
  mode 00755
  recursive true
end

directory "#{node[:zookeeper][:data_dir]}" do
  user "#{node[:zookeeper][:user]}"
  mode 00755
  recursive true
end

execute "install_zookeeper" do
  cwd "#{node[:zookeeper][:root_dir]}"
  command "tar -zxvf #{Chef::Config[:file_cache_path]}/zookeeper-#{node[:zookeeper][:version]}.tar.gz"
  not_if { ::File.exists?("#{node[:zookeeper][:root_dir]}/zookeeper-#{node[:zookeeper][:version]}") }
end

template "setup_zookeeper_config" do
  path "#{node[:zookeeper][:root_dir]}/zookeeper-#{node[:zookeeper][:version]}/conf/zoo.cfg"
  source "zoo.cfg.erb"
  owner node[:zookeeper][:user]
  group node[:zookeeper][:group]
  mode 0744
  variables(
    :data_dir => node['zookeeper']['data_dir'],
    :clientPort => node['zookeeper']['clientPort']
  )
  action :create_if_missing
end

bash "start_zookeeper" do
  user node[:zookeeper][:user]
  cwd "#{node[:zookeeper][:data_dir]}"
  code <<-EOH
    #{node[:zookeeper][:root_dir]}/zookeeper-#{node[:zookeeper][:version]}/bin/zkServer.sh start >>zookeeper.log 2>&1
  EOH
end
