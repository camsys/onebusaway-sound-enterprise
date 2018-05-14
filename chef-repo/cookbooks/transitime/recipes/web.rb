tomcat_instance_name = node[:oba][:tomcat][:instance_name]
tomcat_home_dir = "/var/lib/#{tomcat_instance_name}"
tomcat_start_command = "systemctl start #{tomcat_instance_name}"
tomcat_restart_command = "systemctl restart #{tomcat_instance_name}"


log "Downloading wars"

mvn_version = node[:oba][:mvn][:version_transitime_web]
mvn_web_dest_file = "/tmp/chef/transitimeWebapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_web_dest_file}"
maven "transitimeWebapp" do
  group_id "transitime"
  dest "/tmp/chef"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

mvn_api_dest_file = "/tmp/chef/transitimeApi-#{mvn_version}.war"
log "maven dependency installed at #{mvn_api_dest_file}"
maven "transitimeApi" do
  group_id "transitime"
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

directory "/var/lib/oba/transitime/web" do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  action :create
  recursive true
end

%w{logback-classic-1.1.2.jar logback-core-1.1.2.jar slf4j-api-1.7.2.jar}.each do |jar_file|
  cookbook_file ["#{tomcat_home_dir}/lib", jar_file].compact.join("/") do
    owner node[:tomcat][:user]
    group node[:tomcat][:group]
    source jar_file
    mode  '0444'
  end
end
script "deploy_web_pre" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  sudo service #{tomcat_instance_name} stop
  sudo rm -rf #{tomcat_home_dir}/webapps/*
  sudo unzip #{mvn_web_dest_file} -d #{tomcat_home_dir}/webapps/web || exit 1
  sudo unzip #{mvn_api_dest_file} -d /#{tomcat_home_dir}/webapps/api || exit 1
  sudo rm -f #{tomcat_home_dir}/webapps/web/WEB-INF/classes/transiTimeConfig.xml
  sudo rm -f #{tomcat_home_dir}/webapps/web/WEB-INF/classes/mysql_hibernate.cfg.xml
EOH
end

# NOTE: this does not appear to be read!
template "#{tomcat_home_dir}/webapps/web/WEB-INF/classes/transiTimeConfig.xml" do
  source "web/transitimeConfig.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
# template transitime configuration
template "#{tomcat_home_dir}/webapps/web/WEB-INF/classes/mysql_hibernate.cfg.xml" do
  source "web/mysql_hibernate.cfg.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
template "#{tomcat_home_dir}/webapps/api/WEB-INF/classes/transiTimeConfig.xml" do
  source "web/transitimeConfig.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
# template transitime configuration
template "#{tomcat_home_dir}/webapps/api/WEB-INF/classes/mysql_hibernate.cfg.xml" do
  source "web/mysql_hibernate.cfg.xml.erb"
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
  command "[ '`ps -o rss -u #{tomcat_instance_name} --no-headers`' -gt 5068924 ] && #{tomcat_restart_command}"
  user "root"
end
