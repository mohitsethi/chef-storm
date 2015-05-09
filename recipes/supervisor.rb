include_recipe "storm::default"

bash "start_supervisor" do
  user node[:storm][:user]
  cwd "#{node[:storm][:data_dir]}"
  code <<-EOH
    #{node[:storm][:root_dir]}/apache-storm-#{node[:storm][:version]}/bin/storm supervisor >>supervisor.log 2>&1 &
  EOH
end
