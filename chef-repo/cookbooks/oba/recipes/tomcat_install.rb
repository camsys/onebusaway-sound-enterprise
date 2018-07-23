tomcat_instance_name = node[:oba][:tomcat][:instance_name]
tomcat_home_dir = "/var/lib/#{tomcat_instance_name}"
tomcat_webapp_dir = "#{tomcat_home_dir}/webapps"
tomcat_log_dir = "#{tomcat_home_dir}/logs"
tomcat_work_dir = "/var/cache/#{tomcat_instance_name}/work"


# create tomcat user
user node[:tomcat][:group] do
  system true
end

user node[:tomcat][:user] do
  gid node[:tomcat][:group]
  system true
  shell '/bin/false'
end

group node[:tomcat][:group] do
  action :modify
  members 'ubuntu'
  append true
end

# install tomcat
tomcat_install "#{tomcat_instance_name}" do
  install_path "#{tomcat_home_dir}"
  tomcat_user node[:tomcat][:user]
  tomcat_group node[:tomcat][:group]
end

#delete default tomcat log directory
directory "/var/log/#{tomcat_instance_name}" do
  recursive true
  action :delete
end

#delete default tomcat webapps directory
directory "#{tomcat_webapp_dir}/*" do
  recursive true
  action :delete
end

#delete default tomcat work directory
directory "#{tomcat_work_dir}/*" do
  recursive true
  action :delete
end

# create /etc/tomcat dir
directory "/etc/#{tomcat_instance_name}" do
  recursive true
  action :create
end

#create tomcat log links
link "/var/log/tomcat8" do
  to "#{tomcat_log_dir}"
end

link "/var/log/tomcat7" do
  to "/var/log/tomcat8"
end

link "/var/log/tomcat6" do
  to "/var/log/tomcat7"
end


#set permissions for tomcat
execute "tomcat_permissions" do
  command "chmod 0755 -R #{tomcat_home_dir}"
  user "root"
  action :run
end

tomcat_service "#{tomcat_instance_name}" do
  action :start
  install_path "#{tomcat_home_dir}"
  env_vars [{'CATALINA_HOME' => "#{tomcat_home_dir}"},
            {'CATALINA_OUT' => "#{tomcat_log_dir}/catalina.out"},
            {'JAVA_OPTS' => node[:tomcat][:java_options]}]
  tomcat_user node[:tomcat][:user]
  tomcat_group node[:tomcat][:group]
  notifies :create, "link[/etc/init.d/#{tomcat_instance_name}]", :immediately
end

link "/etc/init.d/#{tomcat_instance_name}" do
  to "/etc/init/#{tomcat_instance_name}.conf"
end

# log rotate
template "/etc/cron.daily/#{tomcat_instance_name}" do
  source "tomcat_log_rotate.erb"
  owner "root"
  group "root"
  mode '0755'
end
