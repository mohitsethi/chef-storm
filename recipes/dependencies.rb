
include_recipe "java::oracle"

node['storm']['packages'].each do |pkg|
  package pkg
end

bash "flush iptables" do
  command "service iptables stop"
end

if node['zookeeper']['required']
  include_recipe "storm::zookeeper"
end

if node['zeromq']['required']
  remote_file "#{Chef::Config[:file_cache_path]}/zeromq-#{node[:zeromq][:version]}.tar.gz" do
    source "#{node['zeromq']['download_url']}/zeromq-#{node[:zeromq][:version]}.tar.gz"
    mode   0744
    action :create_if_missing
  end

  execute "tar" do
    cwd     "#{Chef::Config[:file_cache_path]}"
    command "tar -zxvf #{Chef::Config[:file_cache_path]}/zeromq-#{node[:zeromq][:version]}.tar.gz"
  end

  bash "build_zeromq" do
    cwd "#{Chef::Config[:file_cache_path]}/zeromq-#{node[:zeromq][:version]}"
    code <<-EOH
      (./configure && make)
    EOH
  end

  bash "install_zeromq" do
    cwd "#{Chef::Config[:file_cache_path]}/zeromq-#{node[:zeromq][:version]}"
    code <<-EOH
      make install
      ldconfig
    EOH
  end
end

if node['jzmq']['required']
 
  remote_file "#{Chef::Config[:file_cache_path]}/jzmq-master.zip" do
    source "#{node['jzmq']['download_url']}"
    action :create_if_missing
  end

  execute "unzip" do
    cwd     "#{Chef::Config[:file_cache_path]}"
    command "unzip #{Chef::Config[:file_cache_path]}/jzmq-master.zip"
  end

  bash "build_jzmq" do
    cwd "#{Chef::Config[:file_cache_path]}/jzmq-master"
    code <<-EOH
      (./autogen.sh && ./configure)
    EOH
  end

  bash "install_jzmq" do
    cwd "#{Chef::Config[:file_cache_path]}/jzmq-master"
    code <<-EOH
      make install
    EOH
  end
end
