# app tomcat properties
tomcat_instance_name = node[:oba][:tomcat][:instance_name]
tomcat_home_dir = "/var/lib/#{tomcat_instance_name}"
tomcat_stop_command = "systemctl stop #{tomcat_instance_name}"
tomcat_start_command = "systemctl restart #{tomcat_instance_name}"

# create bundle directory
directory node[:oba][:tds][:bundle_path] do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  action :create
  recursive true
end

# create hsqldb path
directory "/var/lib/oba/db" do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  action :create
  recursive true
end

directory "/var/lib/oba/db/tds" do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  action :create
  recursive true
end

mvn_version = node[:oba][:mvn][:version_app]
mvn_branded_version = node[:oba][:mvn][:version_branded]

log "Downloading wars"
mvn_tdf_dest_file = "/tmp/war/onebusaway-transit-data-federation-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_tdf_dest_file}"
maven "onebusaway-transit-data-federation-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

mvn_api_dest_file = "/tmp/war/onebusaway-api-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_api_dest_file}"
maven "onebusaway-api-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

mvn_sms_dest_file = "/tmp/war/onebusaway-sms-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_sms_dest_file}"
maven "onebusaway-sms-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

mvn_nextbus_api_dest_file = "/tmp/war/onebusaway-nextbus-api-webapp-#{mvn_version}.war"
log "maven dependency installed at #{mvn_nextbus_api_dest_file}"
maven "onebusaway-nextbus-api-webapp" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_version
  packaging "war"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  repositories node[:oba][:mvn][:repositories]
end

front_end_webapp = node[:oba][:webapp][:artifact]
mvn_webapp_dest_file = "/tmp/war/#{front_end_webapp}-#{mvn_branded_version}.war"
log "maven dependency installed at #{mvn_webapp_dest_file}"
maven "#{front_end_webapp}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_branded_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
end

###
# start dev branded test
###
# wmata
maven "#{node[:oba][:wmata_webapp][:artifact]}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_branded_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
  only_if { node[:oba][:env] == "dev" }
end
# sound
maven "#{node[:oba][:sound_webapp][:artifact]}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_branded_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
  only_if { node[:oba][:env] == "dev" }

end
# hart
maven "#{node[:oba][:hart_webapp][:artifact]}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_branded_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
  only_if { node[:oba][:env] == "dev" }
end
# hart
maven "#{node[:oba][:dash_webapp][:artifact]}" do
  group_id node[:oba][:mvn][:group_id]
  dest "/tmp/war"
  version mvn_branded_version
  packaging "war"
  owner node[:tomcat][:user]
  repositories node[:oba][:mvn][:repositories]
  only_if { node[:oba][:env] == "dev" }
end

###
# end dev branded test
###

# template config.json for local configuration
template "/var/lib/oba/config.json" do
  source "app/config.json.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end

# template context.xml adding datasource
template "#{tomcat_home_dir}/conf/context.xml" do
  source "app/context.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

# template service.xml for logging conf
template "#{tomcat_home_dir}/conf/server.xml" do
  source "app/server.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
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
  #{tomcat_stop_command}
  sudo rm -rf #{tomcat_home_dir}/webapps/*
  sudo rm -rf #{tomcat_home_dir}/work/Catalina/localhost/
  sudo rm -rf #{node[:oba][:tds][:bundle_path]}/*
  # deploy tds
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-transit-data-federation-webapp 
  sudo unzip #{mvn_tdf_dest_file} -d #{tomcat_home_dir}/webapps/onebusaway-transit-data-federation-webapp || exit 1
  # deploy api
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-api-webapp
  sudo unzip #{mvn_api_dest_file} -d #{tomcat_home_dir}/webapps/onebusaway-api-webapp || exit 1
  # deploy sms
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-sms-webapp
  sudo unzip #{mvn_sms_dest_file} -d #{tomcat_home_dir}/webapps/onebusaway-sms-webapp || exit 1
  # deploy nextbus-api
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-nextbus-api-webapp
  sudo unzip #{mvn_nextbus_api_dest_file} -d #{tomcat_home_dir}/webapps/onebusaway-nextbus-api-webapp || exit 1
  # deploy enterprise
  sudo mkdir #{tomcat_home_dir}/webapps/ROOT
  sudo unzip #{mvn_webapp_dest_file} -d #{tomcat_home_dir}/webapps/ROOT || exit 1

  EOH
end

###
# start deploy branded webapps
###
# deploy onebusaway-enterprise-wmata-webapp
# deploy onebusaway-enterprise-sound-webapp
# deploy onebusaway-enterprise-hart-webapp
script "deploy_front_end" do
  interpreter "bash"
  user node[:oba][:user]
  cwd node[:oba][:home]
  puts "Branded end version is #{mvn_branded_version}"
  only_if { node[:oba][:env] == "dev" }
  code <<-EOH
  # deploy wmata
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-enterprise-wmata-webapp
  sudo unzip /tmp/war/#{node[:oba][:wmata_webapp][:artifact]}-#{mvn_branded_version}.war -d #{tomcat_home_dir}/webapps/onebusaway-enterprise-wmata-webapp || exit 1
  # deploy sound
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-enterprise-sound-webapp
  sudo unzip /tmp/war/#{node[:oba][:sound_webapp][:artifact]}-#{mvn_branded_version}.war -d #{tomcat_home_dir}/webapps/onebusaway-enterprise-sound-webapp || exit 1
  # deploy wmata
  sudo mkdir #{tomcat_home_dir}/webapps/onebusaway-enterprise-hart-webapp
  sudo unzip /tmp/war/#{node[:oba][:hart_webapp][:artifact]}-#{mvn_branded_version}.war -d #{tomcat_home_dir}/webapps/onebusaway-enterprise-hart-webapp || exit 1
  sudo mkdir #{tomcat_home_dir}/webapps/tracker
  sudo unzip /tmp/war/#{node[:oba][:dash_webapp][:artifact]}-#{mvn_branded_version}.war -d #{tomcat_home_dir}/webapps/tracker || exit 1

  EOH
end

###
# end deploy branded webapps
###

# template tds data-sources
template "#{tomcat_home_dir}/webapps/onebusaway-transit-data-federation-webapp/WEB-INF/classes/data-sources.xml" do
  source "tds/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
# template api data-sources
template "#{tomcat_home_dir}/webapps/onebusaway-api-webapp/WEB-INF/classes/data-sources.xml" do
  source "api/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
# template sms data-sources
template "#{tomcat_home_dir}/webapps/onebusaway-sms-webapp/WEB-INF/classes/data-sources.xml" do
  source "sms/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
# template nextbus api data-sources
template "#{tomcat_home_dir}/webapps/onebusaway-nextbus-api-webapp/WEB-INF/classes/data-sources.xml" do
  source "nextbus-api/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end
# template app data-sources
template "#{tomcat_home_dir}/webapps/ROOT/WEB-INF/classes/data-sources.xml" do
  source "app/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

# we need to do the same for tracker so that xwiki works
# template app data-sources
template "#{tomcat_home_dir}/webapps/tracker/WEB-INF/classes/data-sources.xml" do
  source "tracker/data-sources.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end


# template app urlrewrite
template "#{tomcat_home_dir}/webapps/ROOT/WEB-INF/urlrewrite.xml" do
  source "app/urlrewrite.xml.erb"
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
end

# TODO fix build dependency
%w{mysql-connector-java-5.1.35.jar}.each do |jar_file|
  cookbook_file ["#{tomcat_home_dir}/lib", jar_file].compact.join("/") do
    owner node[:tomcat][:user]
    group node[:tomcat][:group]
    source ["admin", jar_file].compact.join("/")
    mode  '0444'
  end
end

# start up tomcat
script "start_front_end" do
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
