# create bundle directory
directory node[:oba][:tds][:bundle_path] do
  owner "tomcat7"
  group "tomcat7"
  action :create
end

log "Downloading wars"
mvn_tdf_dest_file = "/tmp/onebusaway-transit-data-federation-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_tdf_dest_file}"
maven "onebusaway-transit-data-federation-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

mvn_version = node[:oba][:mvn][:version_app]
mvn_api_dest_file = "/tmp/onebusaway-api-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_api_dest_file}"
maven "onebusaway-api-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

front_end_webapp = node[:oba][:webapp][:artifact]
mvn_webapp_dest_file = "/tmp/#{front_end_webapp}-#{mvn_version}.war"
log "maven dependency installed at #{mvn_webapp_dest_file}"
maven "#{front_end_webapp}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp"
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

# deploy onebusaway-api-webapp
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
# template app data-sources
template "#{node[:tomcat][:webapp_dir]}/ROOT/WEB-INF/classes/data-sources.xml" do
  source "app/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
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
