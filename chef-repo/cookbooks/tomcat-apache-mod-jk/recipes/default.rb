#
# Cookbook Name:: tomcat-apache-mod-jk
# Recipe:: default
#
# install required os dependencies
%w{ libapache2-mod-jk }.each do |g| 
  package g do
    action :install
  end
end

include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_jk"

script "move_aside_config" do
  interpreter "bash"
  user node[:oba][:user]
  cwd node[:oba][:home]
  code <<-EOH
  if [ -f "/var/lib/tomcat#{node['tomcat']['base_version']}/conf/server.xml" ]; then
    sudo mv "/var/lib/tomcat#{node['tomcat']['base_version']}/conf/server.xml" "/var/lib/tomcat#{node['tomcat']['base_version']}/conf/server.xml.chef"
  fi
  if [ -f "/etc/apache2/mods-enabled/jk.conf" ]; then
    sudo mv /etc/apache2/mods-enabled/jk.conf /etc/apache2/mods-enabled/jk.conf.chef
  fi
  if [ -f "/etc/apache2/sites-available/default" ]; then
    sudo mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.chef
  fi
  if [ -f "/etc/libapache2-mod-jk/workers.properties" ]; then
    sudo mv /etc/libapache2-mod-jk/workers.properties /etc/libapache2-mod-jk/workers.properties.chef
  fi
  EOH
end

template "/var/lib/tomcat#{node['tomcat']['base_version']}/conf/server.xml" do
  source "server.xml.erb"
  owner node[:oba][:user]
  group node[:oba][:user]
  mode "0644"
  #notifies :restart, resources(:service => "tomcat")
end

# worker.properties
template "/etc/libapache2-mod-jk/workers.properties" do
  source "workers.properties.erb"
  owner node[:oba][:user]
  group node[:oba][:user]
  mode "0644"
  notifies :restart, resources(:service => "apache2")
end

# mod_jk
template node[:oba][:mod_jk] do
    source "jk.erb"
    owner "www-data"
    group "www-data"
    mode "0644"
    notifies :restart, resources(:service => "apache2")
end


# template /etc/apache2/sites-available/default
if node['apache']['version'] == '2.2'
  template node[:oba][:sites_available] do
     source "site-definition.erb"
     owner "www-data"
     group "www-data"
     mode "0644"
     notifies :restart, resources(:service => "apache2")
  end
elsif node['apache']['version'] == '2.4'
  template node[:oba][:sites_available_2_4] do
     source "site-definition.erb"
     owner "www-data"
     group "www-data"
     mode "0644"
     notifies :restart, resources(:service => "apache2")
  end
  link "/etc/apache2/sites-enabled/default.conf" do
    to "/etc/apache2/sites-available/default.conf"
  end
end

# deploy robots.txt
template node[:oba][:robots_file] do
    source "robots.txt.erb"
    owner "root"
    group "root"
    mode "0644"
end


