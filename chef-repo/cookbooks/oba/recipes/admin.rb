log "Downloading wars"

mvn_admin_version = node[:oba][:mvn][:version_admin]
mvn_admin_dest_file = "/tmp/war/onebusaway-admin-webapp-#{mvn_admin_version}.war"
log "maven dependency installed at #{mvn_admin_dest_file}"
maven "onebusaway-admin-webapp" do
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

link "/var/log/tomcat6" do
 to "/var/log/tomcat7"
end

["/var/lib/oba", "/var/lib/oba/bundle","/var/lib/oba/bundles/staged", "/var/lib/oba/bundles/active", "/var/lib/oba/bundles/builder"].each do |path|
  directory path do
    owner "tomcat7"
    group "tomcat7"
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

# deploy onebusaway-admin-webapp
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

template "/etc/init.d/tomcat7-watchdog" do
  source "watchdog/watchdog.init.erb"
  owner 'root'
  group 'root'
  mode '0755'
end
# template context.xml adding datasource
template "/var/lib/tomcat7-watchdog/conf/context.xml" do
  source "admin/context.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end


script "stop_watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  service tomcat7-watchdog stop
  EOH
end unless ::File.exists?("/var/lib/tomcat7-watchdog")

script "deploy_watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "watcdog version is #{mvn_version}"
  code <<-EOH
  rm -rf /var/lib/tomcat7-watchdog/webapps/*
  rm -rf /var/cache/tomcat7-watchdog/temp/*
  rm -rf /var/cache/tomcat7-watchdog/work/Catalina/localhost/
  unzip #{mvn_watchdog_dest_file} -d /var/lib/tomcat7-watchdog/webapps/onebusaway-watchdog-webapp || exit 1
  EOH
end




# template data-sources
template "/var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/data-sources.xml" do
  source "admin/data-sources.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
template "/var/lib/tomcat7-watchdog/webapps/onebusaway-watchdog-webapp/WEB-INF/classes/data-sources.xml" do
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

script "start_tomcats" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "admin version is #{mvn_version}"
  code <<-EOH
  service tomcat7 start
  service tomcat7-watchdog start
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
  mode '0600'
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
  user "tomcat7"
  cwd node[:oba][:home]
  puts "syncing bundles"
  code <<-EOH
  sed -i /etc/passwd -e 's!/usr/share/tomcat7:/bin/false!/usr/share/tomcat7:/bin/bash!'
  nohup /usr/bin/s3cmd --config /home/ubuntu/.s3cfg --no-progress --recursive --rexclude "/$" --skip-existing get s3://obawmata-bundle/#{node[:oba][:env]}/ /var/lib/oba/ >/var/lib/oba/logs/bundle_sync.log 2>&1 &
  EOH
end


# ubuntu memory default for tomcat is not enough
script "fixup watchdog" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  puts "fixing memory args"
  code <<-EOH
  sed -i /etc/init.d/tomcat7-watchdog -e 's!Xmx128m!Xmx2g!g'
  sudo service tomcat7-watchdog restart
  EOH
end

