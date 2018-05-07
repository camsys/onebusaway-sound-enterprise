log "Downloading wars"

tomcat_instance_name = "tomcat8"
tomcat_stop_command = "systemctl #{tomcat_instance_name} stop"
tomcat_start_command = "systemctl #{tomcat_instance_name} start"
tomcat_webapp_dir = "/var/lib/#{tomcat_instance_name}/webapps"
tomcat_temp_dir = "/var/cache/#{tomcat_instance_name}/temp"
tomcat_work_dir = "/var/cache/#{tomcat_instance_name}/work"
tomcat_lib_dir = "/var/lib/#{tomcat_instance_name}/lib"
tomcat_user = "tomcat8"
tomcat_group = "tomcat8"

## watchdog properties
tomcat_w_instance_Name = "tomcat8-watchdog"
tomcat_w_stop_command = "systemctl #{tomcat_w_instance_name} stop"
tomcat_w_start_command = "systemctl #{tomcat_w_instance_name} start"
tomcat_w_webapp_dir = "/var/lib/#{tomcat_w_instance_name}/webapps"
tomcat_w_temp_dir = "/var/cache/#{tomcat_w_instance_name}/temp"
tomcat_w_work_dir = "/var/cache/#{tomcat_w_instance_name}/work"

mvn_admin_version = node[:oba][:mvn][:version_admin]
mvn_admin_dest_file = "/tmp/war/onebusaway-admin-webapp-#{mvn_admin_version}.war"
log "maven dependency installed at #{mvn_admin_dest_file}"
maven "onebusaway-admin-webapp" do
  group_id "org.onebusaway"
  dest "/tmp/war"
  version mvn_admin_version
  packaging "war"
  owner "tomcat_user"
  repositories node[:oba][:mvn][:repositories]
end

mvn_version = node[:oba][:mvn][:version_app]
mvn_watchdog_dest_file = "/tmp/war/onebusaway-watchdog-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_watchdog_dest_file}"
maven "onebusaway-watchdog-webapp" do
  group_id "org.onebusaway"
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner "tomcat_user"
  repositories node[:oba][:mvn][:repositories]
end

#tomcat_lib = '/var/lib/tomcat7/lib'
#directory tomcat_lib do
#  owner "tomcat_user"
#  group "tomcat_group"
#  action :create
#end

link "/var/log/tomcat6" do
 to "/var/log/tomcat7"
end

["/var/lib/oba", "/var/lib/oba/bundle","/var/lib/oba/bundles/staged", "/var/lib/oba/bundles/active", "/var/lib/oba/bundles/builder"].each do |path|
  directory path do
    owner "tomcat_user"
    group "tomcat_group"
    action :create
    recursive true
  end
end

["/var/lib/oba/logs"].each do |path|
  directory path do
    owner "ubuntu"
    group "ubuntu"
    action :create
    recursive true
  end
end

# template context.xml adding datasource
template "/etc/#{tomcat_instance_name}/context.xml" do
  source "admin/context.xml.erb"
  owner "tomcat_user"
  group "tomcat_group"
  mode '0644'
end

template "/var/lib/oba/config.json" do
  source "admin/config.json.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

# template apache sites-available
# see https://help.ubuntu.com/10.04/serverguide/httpd.html
template "/etc/apache2/sites-available/default.conf" do
  source "admin/default.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

# deploy onebusaway-admin-webapp
log "war file is #{mvn_admin_dest_file}"
script "deploy_admin" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  service tomcat7 stop
  rm -rf #{tomcat_webapp_dir}/*
  rm -rf /var/cache/tomcat7/temp/*
  rm -rf /var/cache/tomcat7/work/Catalina/localhost/
  if [ ! -e /usr/bin/python2.5 ]
  then
    ln -s /usr/bin/python /usr/bin/python2.5
  fi
  unzip #{mvn_admin_dest_file} -d #{tomcat_webapp_dir}/ROOT || exit 1
  rm -f #{tomcat_webapp_dir}/ROOT/WEB-INF/lib/mysql-connector-java-5.1.17.jar
  EOH
end


# install tomcat-user support
script "install_tomcat_user" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  apt-get install -y tomcat7-user
  cd /var/lib
  /usr/bin/tomcat7-instance-create -p 7070 -c 7005 tomcat7-watchdog || exit 1
  # the policy scripts are not created above sadly
  cp -r /var/lib/tomcat7/conf/policy.d /var/lib/tomcat7-watchdog/conf/
  # bin dir is missing a well
  cp -r /usr/share/tomcat7 /usr/share/tomcat7-watchdog
  mkdir -p /var/lib/tomcat7-watchdog/work/Catalina/localhost
  chown -R tomcat7:tomcat7 tomcat7-watchdog

  EOH
  end unless ::File.exists?("/var/lib/tomcat7-watchdog")

+tomcat_install tomcat_w_instance_name do
  install_path '/var/lib/tomcat8-watchdog'
  exclude_manager true
  exclude_hostmanager true
  action :start
 end

 template "/etc/default/#{tomcat_w_instance_Name}" do
  source "watchdog/#{tomcat_w_instance_Name}.default.erb"
  owner 'root'
  group 'root'
  mode '0644'
end


# template context.xml adding datasource
template "/var/lib/#{tomcat_w_instance_Name}/conf/context.xml" do
  source "admin/context.xml.erb"
  owner "tomcat_user"
  group "tomcat_group"
  mode '0644'
end


script "stop_watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  #{tomcat_w_stop_command}
  EOH
end unless ::File.exists?("/var/lib/tomcat7-watchdog")

script "deploy_watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "watchdog version is #{mvn_version}"
  code <<-EOH
  rm -rf #{tomcat_w_webapp_dir}/*
  rm -rf #{tomcat_w_temp_dir}/*
  rm -rf #{tomcat_w_work_dir}/Catalina/localhost/
  unzip #{mvn_watchdog_dest_file} -d /var/lib/tomcat7-watchdog/webapps/onebusaway-watchdog-webapp || exit 1
  sed -i /etc/passwd -e 's!/usr/share/tomcat7:/bin/false!/usr/share/tomcat7:/bin/bash!'
  EOH
end

# template data-sources
template "#{tomcat_webapp_dir}/ROOT/WEB-INF/classes/data-sources.xml" do
  source "admin/data-sources.xml.erb"
  owner "tomcat_user"
  group "tomcat_group"
  mode '0644'
end
template "#{tomcat_w_webapp_dir}/webapps/onebusaway-watchdog-webapp/WEB-INF/classes/data-sources.xml" do
  source "watchdog/data-sources.xml.erb"
  owner "tomcat_user"
  group "tomcat_group"
  mode '0644'
end


# TODO fix build dependency
%w{mysql-connector-java-5.1.35.jar mail-1.4.jar}.each do |jar_file|
  cookbook_file ["#{tomcat_lib_dir}", jar_file].compact.join("/") do
    owner "tomcat_user"
    group "tomcat_group"
    source ["admin", jar_file].compact.join("/")
    mode  '0444'
  end
end

script "start_tomcats" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  #{tomcat_start_command}
  #{tomcat_w_start_command}
  # somewhere along the way ROOT owns this dir, fix it
  sudo chown -R tomcat7:tomcat7 /var/lib/oba/bundles
  EOH
end

# monitoring directory
directory '/var/lib/oba/monitoring' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

# apt-get install s3cmd
%w{s3cmd}.each do |p|
  package p do
    action :install
  end
end

# template s3cfg to ~/.s3cfg
template "/home/ubuntu/.s3cfg" do
  source "admin/s3cfg.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end

# in case we decide to run logrotate on these files
logfiles = []
cron "bundle-sync" do
  minute "0"
  logfile = "/var/lib/oba/logs/bundle_sync.log"
  command "/usr/bin/s3cmd --config /home/ubuntu/.s3cfg --no-progress --recursive --rexclude \"/$\" --skip-existing sync /var/lib/oba/bundles s3://obawmata-bundle/#{node[:oba][:env]}/ > #{logfile} 2>&1"
  user "ubuntu"
  logfiles << logfile
end

## synch bundles
script "sync-bundles-now" do
  interpreter "bash"
  user "tomcat_user"
  cwd node[:oba][:home]
  puts "syncing bundles"
  code <<-EOH
  /usr/bin/s3cmd --config /home/ubuntu/.s3cfg --no-progress --recursive --rexclude "/$" --skip-existing get s3://obawmata-bundle/#{node[:oba][:env]}/ /var/lib/oba/ >/tmp/bundle_sync.log 2>&1
  EOH
end

# now that the bundle is present restart watchdog
script "restart watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "restart watchdog"
  code <<-EOH
  #{tomcat_w_stop_command}
  #{tomcat_w_start_command}
  EOH
end

