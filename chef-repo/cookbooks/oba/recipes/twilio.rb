## twilio properties
tomcat_t_instance_name = "tomcat8-twilio"
tomcat_t_stop_command = "systemctl stop tomcat8_twilio"
tomcat_t_start_command = "systemctl start tomcat8_twilio"

tomcat_t_home_dir = "/var/lib/#{tomcat_t_instance_name}"
tomcat_t_webapp_dir = "/var/lib/#{tomcat_t_instance_name}/webapps"
tomcat_t_temp_dir = "/var/cache/#{tomcat_t_instance_name}/temp"
tomcat_t_work_dir = "/var/cache/#{tomcat_t_instance_name}/work"


# get twilio from maven
mvn_twilio_version = node[:oba][:mvn][:version_twilio]
mvn_twilio_dest_file = "/tmp/war/onebusaway-twilio-webapp-#{mvn_twilio_version}.war"
log "maven dependency installed at #{mvn_twilio_dest_file}"
maven "onebusaway-twilio-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_twilio_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
end

# install tomcat instance for twilio
tomcat_install "twilio" do
  install_path "#{tomcat_t_home_dir}"
  exclude_manager true
  exclude_hostmanager true
  tomcat_user node[:tomcat][:user]
  tomcat_group node[:tomcat][:group]
end

template "/etc/default/twilio" do
  source "twilio/#{tomcat_t_instance_name}.default.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

# template context.xml adding datasource
template "#{tomcat_t_home_dir}/conf/context.xml" do
  source "twilio/context.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

script "stop_twilio" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  ignore_failure true
  code <<-EOH
  #{tomcat_t_stop_command}
  EOH
end unless ::File.exists?("#{tomcat_t_home_dir}")

script "deploy_twilio" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "twilio version is #{mvn_twilio_version}"
  code <<-EOH
  rm -rf #{tomcat_t_webapp_dir}/*
  rm -rf #{tomcat_t_temp_dir}/*
  rm -rf #{tomcat_t_work_dir}/Catalina/localhost/
  unzip #{mvn_twilio_dest_file} -d #{tomcat_t_home_dir}/webapps/onebusaway-twilio-webapp || exit 1
  EOH
end

# template data-sources
template "#{tomcat_t_webapp_dir}/onebusaway-twilio-webapp/WEB-INF/classes/data-sources.xml" do
  source "twilio/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

# twilio server config
template "#{tomcat_t_home_dir}/conf/server.xml" do
  source "twilio/server.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

script "start_tomcat_twilio" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "twilio version is #{mvn_twilio_version}"
  code <<-EOH
  #{tomcat_t_start_command}
  EOH
end
