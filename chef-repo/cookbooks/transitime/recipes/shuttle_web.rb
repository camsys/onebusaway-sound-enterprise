tomcat_instance_name = node[:oba][:tomcat][:instance_name]
tomcat_home_dir = "/var/lib/#{tomcat_instance_name}"
tomcat_start_command = "systemctl start tomcat_#{tomcat_instance_name}"
tomcat_restart_command = "systemctl restart tomcat_#{tomcat_instance_name}"


log "Downloading wars"

mvn_version = node[:oba][:mvn][:version_shuttle_transitime_web]
mvn_web_dest_file = "/tmp/chef/transitclockWebapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_web_dest_file}"
maven "transitclockWebapp" do
  group_id "TheTransitClock"
  dest "/tmp/chef"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

mvn_api_dest_file = "/tmp/chef/transitclockApi-#{mvn_version}.war"
log "maven dependency installed at #{mvn_api_dest_file}"
maven "transitclockApi" do
  group_id "TheTransitClock"
  dest "/tmp/chef"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

tomcat_lib = "#{tomcat_home_dir}/lib"
directory tomcat_lib do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  action :create
end

# template context.xml adding datasource
template "#{tomcat_home_dir}/conf/context.xml" do
  source "web/context.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

directory "/var/lib/oba/transitime/web/config" do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  action :create
  recursive true
end


script "deploy_web_pre" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  sudo service tomcat_#{tomcat_instance_name} stop
  sudo rm -rf #{tomcat_home_dir}/webapps/*
  sudo unzip #{mvn_web_dest_file} -d #{tomcat_home_dir}/webapps/web || exit 1
  sudo unzip #{mvn_api_dest_file} -d /#{tomcat_home_dir}/webapps/api || exit 1
  sudo rm -f #{tomcat_home_dir}/webapps/web/WEB-INF/classes/transiTimeConfig.xml
  sudo rm -f #{tomcat_home_dir}/webapps/web/WEB-INF/classes/mysql_hibernate.cfg.xml
  sudo rm -f #{tomcat_home_dir}/webapps/api/WEB-INF/classes/mysql_hibernate.cfg.xml
  EOH
end


template "/var/lib/oba/transitime/web/transitClockWebConfig.properties" do
  source "shuttle-web/transitClockWebConfig.properties.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

template "/var/lib/oba/transitime/web/mysql_hibernate.cfg.xml" do
  source "shuttle-web/mysql_hibernate.cfg.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

# template transitime configuration
#template "#{tomcat_home_dir}/webapps/web/WEB-INF/classes/mysql_hibernate.cfg.xml" do
#  source "shuttle-web/mysql_hibernate.cfg.xml.erb"
#  owner node[:tomcat][:user]
#  group node[:tomcat][:group]
#  mode '0644'
#end
#template "#{tomcat_home_dir}/webapps/api/WEB-INF/classes/transiTimeConfig.xml" do
#  source "shuttle-web/transitimeConfig.xml.erb"
#  owner node[:tomcat][:user]
#  group node[:tomcat][:group]
#  mode '0644'
#end

# template transitime configuration
#template "#{tomcat_home_dir}/webapps/api/WEB-INF/classes/mysql_hibernate.cfg.xml" do
#  source "shuttle-web/mysql_hibernate.cfg.xml.erb"
#  owner node[:tomcat][:user]
#  group node[:tomcat][:group]
#  mode '0644'
#end

template "/var/lib/oba/transitime/web/logback.xml" do
  source "shuttle-web/logback.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

script "deploy_web_post" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  #{tomcat_start_command}
  EOH
end

# monitoring directory
directory '/var/lib/oba/monitoring' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

cron "check-tomcat-size" do
  command "[ `ps -o rss -u tomcat_user --no-headers` -gt 1637312 ] && #{tomcat_restart_command}"
  user "root"
end
