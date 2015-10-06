# create bundle directory
directory node[:oba][:tds][:bundle_path] do
  owner "tomcat7"
  group "tomcat7"
  action :create
  recursive true
end

link "/var/log/tomcat6" do
 to "/var/log/tomcat7"
end

mvn_version = node[:oba][:mvn][:version_app]

log "Downloading wars"
mvn_tdf_dest_file = "/tmp/war/onebusaway-transit-data-federation-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_tdf_dest_file}"
maven "onebusaway-transit-data-federation-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

mvn_api_dest_file = "/tmp/war/onebusaway-api-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_api_dest_file}"
maven "onebusaway-api-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

mvn_sms_dest_file = "/tmp/war/onebusaway-sms-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_sms_dest_file}"
maven "onebusaway-sms-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

mvn_nextbus_api_dest_file = "/tmp/war/onebusaway-nextbus-api-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_nextbus_api_dest_file}"
maven "onebusaway-nextbus-api-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

front_end_webapp = node[:oba][:webapp][:artifact]
mvn_webapp_dest_file = "/tmp/war/#{front_end_webapp}-#{mvn_version}.war"
log "maven dependency installed at #{mvn_webapp_dest_file}"
maven "#{front_end_webapp}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

# template context.xml adding datasource
template "/var/lib/tomcat7/conf/context.xml" do
  source "app/context.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

# template service.xml for logging conf
template "/var/lib/tomcat7/conf/server.xml" do
  source "app/server.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

# deploy onebusaway-api-webapp
# deploy onebusaway-sms-webapp
# deploy onebusaway-nextbus-api-webapp
# deploy onebusaway-transit-data-federation-webapp
# deploy onebusaway-enterprise-(acta|branded)-webapp
# install ie
script "deploy_front_end" do
  interpreter "bash"
  user node[:oba][:user]
  cwd node[:oba][:home]
  puts "Front end version is #{mvn_version}"
  code <<-EOH
  sudo service tomcat7 stop
  sudo rm -rf #{node[:tomcat][:webapp_dir]}/*
  sudo rm -rf #{node[:tomcat][:tmp_dir]}/*
  sudo rm -rf #{node[:tomcat][:base]}/work/Catalina/localhost/
  sudo rm -rf #{node[:oba][:tds][:bundle_path]}/*
  # deploy tds
  sudo mkdir #{node[:tomcat][:webapp_dir]}/onebusaway-transit-data-federation-webapp 
  sudo unzip #{mvn_tdf_dest_file} -d #{node[:tomcat][:webapp_dir]}/onebusaway-transit-data-federation-webapp || exit 1
  # deploy api
  sudo mkdir #{node[:tomcat][:webapp_dir]}/onebusaway-api-webapp
  sudo unzip #{mvn_api_dest_file} -d #{node[:tomcat][:webapp_dir]}/onebusaway-api-webapp || exit 1
  # deploy sms
  sudo mkdir #{node[:tomcat][:webapp_dir]}/onebusaway-sms-webapp
  sudo unzip #{mvn_sms_dest_file} -d #{node[:tomcat][:webapp_dir]}/onebusaway-sms-webapp || exit 1
  # deploy nextbus-api
  sudo mkdir #{node[:tomcat][:webapp_dir]}/onebusaway-nextbus-api-webapp
  sudo unzip #{mvn_nextbus_api_dest_file} -d #{node[:tomcat][:webapp_dir]}/onebusaway-nextbus-api-webapp || exit 1
  # deploy enterprise
  sudo mkdir #{node[:tomcat][:webapp_dir]}/ROOT
  sudo unzip #{mvn_webapp_dest_file} -d #{node[:tomcat][:webapp_dir]}/ROOT || exit 1

  EOH
end

# template tds data-sources
template "#{node[:tomcat][:webapp_dir]}/onebusaway-transit-data-federation-webapp/WEB-INF/classes/data-sources.xml" do
  source "tds/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
# template api data-sources
template "#{node[:tomcat][:webapp_dir]}/onebusaway-api-webapp/WEB-INF/classes/data-sources.xml" do
  source "api/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
# template sms data-sources
template "#{node[:tomcat][:webapp_dir]}/onebusaway-sms-webapp/WEB-INF/classes/data-sources.xml" do
  source "sms/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
# template nextbus api data-sources
template "#{node[:tomcat][:webapp_dir]}/onebusaway-nextbus-api-webapp/WEB-INF/classes/data-sources.xml" do
  source "nextbus-api/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
# template app data-sources
template "#{node[:tomcat][:webapp_dir]}/ROOT/WEB-INF/classes/data-sources.xml" do
  source "app/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

# TODO fix build dependency
%w{mysql-connector-java-5.1.35.jar}.each do |jar_file|
  cookbook_file ["/usr/share/tomcat7/lib", jar_file].compact.join("/") do
    owner 'tomcat7'
    group 'tomcat7'
    source ["admin", jar_file].compact.join("/")
    mode  '0444'
  end
end

# start up tomcat
script "start_front_end" do
  interpreter "bash"
  user node[:oba][:user]
  cwd node[:oba][:home]
  code <<-EOH
  sudo service tomcat7 start
  EOH
end
