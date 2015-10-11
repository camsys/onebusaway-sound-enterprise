log "Downloading wars"

mvn_admin_version = node[:oba][:mvn][:version_nyc]
mvn_admin_dest_file = "/tmp/war/onebusaway-nyc-admin-webapp-#{mvn_admin_version}.war"
log "maven dependency installed at #{mvn_admin_dest_file}"
maven "onebusaway-nyc-admin-webapp" do
  group_id "org.onebusaway"
  dest "/tmp/war"
  version mvn_admin_version
  packaging "war"
  owner "tomcat7"
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
  owner "tomcat7"
  repositories node[:oba][:mvn][:repositories]
end

#tomcat_lib = '/var/lib/tomcat7/lib'
#directory tomcat_lib do
#  owner "tomcat7"
#  group "tomcat7"
#  action :create
#end

["/var/lib/oba", "/var/lib/oba/bundle",  "/var/lib/obanyc", "/var/lib/obanyc/wm_bundles", "/var/lib/obanyc/bundles/staged", "/var/lib/obanyc/activebundles"].each do |path|
  directory path do
    owner "tomcat7"
    group "tomcat7"
    action :create
    recursive true
  end
end

# template context.xml adding datasource
template "/etc/tomcat7/context.xml" do
  source "admin/context.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

template "/var/lib/obanyc/config.json" do
  source "admin/config.json.erb"
  owner 'root'
  group 'root'
  mode '0644'
end


# deploy onebusaway-nyc-admin-webapp
log "war file is #{mvn_admin_dest_file}"
script "deploy_admin" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  service tomcat7 stop
  rm -rf /var/lib/tomcat7/webapps/*
  rm -rf /var/cache/tomcat7/temp/*
  rm -rf /var/cache/tomcat7/work/Catalina/localhost/
  if [ ! -e /usr/bin/python2.5 ]
  then
    ln -s /usr/bin/python /usr/bin/python2.5
  fi
  unzip #{mvn_admin_dest_file} -d /var/lib/tomcat7/webapps/ROOT || exit 1
  rm -f /var/lib/tomcat7/webapps/ROOT/WEB-INF/lib/mysql-connector-java-5.1.17.jar
  unzip #{mvn_watchdog_dest_file} -d /var/lib/tomcat7/webapps/watchdog || exit 1
  EOH
end

# template data-sources
template "/var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/data-sources.xml" do
  source "admin/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
template "/var/lib/tomcat7/webapps/watchdog/WEB-INF/classes/data-sources.xml" do
  source "watchdog/data-sources.xml.erb"
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

script "start_admin" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  service tomcat7 start
  EOH
end


