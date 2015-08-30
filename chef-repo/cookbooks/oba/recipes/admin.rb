log "Downloading wars"

mvn_version = node[:oba][:mvn][:version_nyc]
mvn_dest_file = "/tmp/onebusaway-nyc-admin-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_dest_file}"
maven "onebusaway-nyc-admin-webapp" do
  group_id "org.onebusaway"
  dest "/tmp"
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

directory "/var/lib/oba" do
  owner "tomcat7"
  group "tomcat7"
  action :create
end

directory "/var/lib/obanyc" do
  owner "tomcat7"
  group "tomcat7"
  action :create
end

directory "/var/lib/obanyc/bundles/staged" do
  owner "tomcat7"
  group "tomcat7"
  action :create
  recursive true
end

# template context.xml adding datasource
template "/etc/tomcat7/context.xml" do
  source "admin/context.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

template "/var/lib/oba/config.json" do
  source "admin/config.json.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

template "/var/lib/obanyc/config.json" do
  source "admin/config.json.erb"
  owner 'root'
  group 'root'
  mode '0644'
end


# deploy onebusaway-nyc-admin-webapp
log "war file is #{mvn_dest_file}"
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
  unzip #{mvn_dest_file} -d /var/lib/tomcat7/webapps/ROOT || exit 1
  rm -f /var/lib/tomcat7/webapps/ROOT/WEB-INF/lib/mysql-connector-java-5.1.17.jar
  EOH
end

# template data-sources
template "/var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/data-sources.xml" do
  source "admin/data-sources.xml.erb"
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

script "deploy_admin" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  service tomcat7 start
  EOH
end

#service "tomcat7" do
#  provider Chef::Provider::Service::Upstart
#  supports :restart => true, :stop => true, :start => true
#  action [:restart]
#end

# restart to pick up SSL changes
#service "apache2" do
#  supports :restart => true, :stop => true, :start => true
#  action [:restart]
#end

## CHEF-2816: cron does not support @reboot
# script "admin_reboot_cron" do
#   interpreter "bash"
#   user "root"
#   cwd node[:oba][:home]
#   code <<-EOH
#   crontab -l >/tmp/crontab.root
#   grep -q -e reboot /tmp/crontab.root
#   if [ $? -eq 1  ]
#   then
#     echo "@reboot /usr/local/bin/chef-client >/home/ubuntu/chef-client.log 2>&1" >>/tmp/crontab.root
#     cat /tmp/crontab.root | crontab
#  fi
# EOH
# end

