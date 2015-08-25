log "Downloading wars"

mvn_version = node[:oba][:mvn][:version_transitime_web]
mvn_web_dest_file = "/tmp/transitimeWebapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_web_dest_file}"
maven "transitimeWebapp" do
  group_id "transitime"
  dest "/tmp"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

mvn_api_dest_file = "/tmp/transitimeApi-#{mvn_version}.war"
log "maven dependency installed at #{mvn_api_dest_file}"
maven "transitimeApi" do
  group_id "transitime"
  dest "/tmp"
  version mvn_version
  packaging "war"
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

tomcat_lib = '/var/lib/tomcat7/lib'
directory tomcat_lib do
  owner "tomcat7"
  group "tomcat7"
  action :create
end

# template context.xml adding datasource
template "/var/lib/tomcat7/conf/context.xml" do
  source "web/context.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

directory "/var/lib/oba/transitime/web" do
  owner 'tomcat7'
  group 'tomcat7'
  action :create
  recursive true
end


# template transitime ocnfiguration
template "/var/lib/oba/transitime/web/transitimeConfig.xml" do
  source "web/transitimeConfig.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

script "deploy_web" do
  interpreter "bash"
#  user node[:oba][:user]
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  sudo service tomcat7 stop
  sudo rm -rf /var/lib/tomcat7/webapps/*
  sudo unzip #{mvn_web_dest_file} -d /var/lib/tomcat7/webapps/web || exit 1
  sudo unzip #{mvn_api_dest_file} -d /var/lib/tomcat7/webapps/api || exit 1
  sudo service tomcat7 start
EOH
end
