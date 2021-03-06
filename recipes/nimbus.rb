include_recipe "storm::default"

bash "start_nimbus" do
  user node[:storm][:user]
  cwd "#{node[:storm][:data_dir]}"
  code <<-EOH
  pid=$(pgrep -f backtype.storm.daemon.nimbus)
  if [ -z $pid ]; then
    #{node[:storm][:root_dir]}/apache-storm-#{node[:storm][:version]}/bin/storm nimbus >>nimbus.log 2>&1 &
  fi
  EOH
end

bash "start_ui" do
  user node[:storm][:user]
  cwd "#{node[:storm][:data_dir]}"
  code <<-EOH
  pid=$(pgrep -f backtype.storm.ui.core)
  if [ -z $pid ]; then
    #{node[:storm][:root_dir]}/apache-storm-#{node[:storm][:version]}/bin/storm ui >>ui.log 2>&1 &
  fi
  EOH
end
