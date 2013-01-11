#
# Cookbook Name:: passenger_env_vars
# Recipe:: default
#

service "nginx" do
  action :nothing
  supports :restart => true
end

if ['app_master', 'app', 'solo'].include?(node[:role])
  node[:applications].each do |app_name, data|
    template "/data/#{app_name}/shared/config/env.custom" do
      source "env.custom.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0755
      backup 0
      notifies :restart, resources(:service => "nginx"), :delayed
    end

    template "/data/#{app_name}/shared/config/passenger_ruby_wrapper" do
      source "passenger_ruby_wrapper.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0755
      backup 0
      variables(:app_name => app_name)
      notifies :restart, resources(:service => "nginx"), :delayed
    end
    
    template "/etc/nginx/http-custom.conf" do
      source "http-custom.conf"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0755
      backup 0
      variables(:app_name => app_name)
      notifies :restart, resources(:service => "nginx"), :delayed
    end
  end
end