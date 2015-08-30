# create bundle directory
directory node[:oba][:ie][:bundle_path] do
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

front_end_webapp = node[:oba][:webapp] 
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


service "tomcat7" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :stop => true, :start => true
  action [:stop]
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
# deploy onebusaway-enterprise-webapp
# install ie
script "deploy_front_end" do
  interpreter "bash"
  user node[:oba][:user]
  cwd node[:oba][:home]
  puts "Front end version is #{mvn_version}"
  code <<-EOH
  sleep 10
  sudo rm -rf #{node[:tomcat][:webapp_dir]}/*
  sudo rm -rf #{node[:tomcat][:tmp_dir]}/*
  sudo rm -rf #{node[:tomcat][:base]}/work/Catalina/localhost/
#  sudo rm -rf #{node[:oba][:ie][:bundle_path]}/*
  sudo mv #{mvn_api_dest_file} #{node[:tomcat][:webapp_dir]}/onebusaway-api-webapp.war || exit 1
  sudo mv #{mvn_webapp_dest_file} #{node[:tomcat][:webapp_dir]}/ROOT.war || exit 1
  sudo mv #{mvn_tdf_dest_file} #{node[:tomcat][:webapp_dir]}/onebusaway-transit-data-federation-webapp.war || exit 1
  EOH
end

service "tomcat7" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :stop => true, :start => true
  action [:start]
end
