log "Downloading wars"

override_attributes(:maven => {
                      :m2_home => '/var/lib/maven'
                    },
                    :tomcat => {
                      :java_options => '-Xmx3G -Xms1G -XX:MaxPermSize=256m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Dtransitime.rmi.timeoutSec=300 -Dtransitime.db.encryptionPassword=#{node["transitime"]["encryptionPassword"]}'
                    }
)

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
# template "/var/lib/oba/transitime/web/transitimeConfig.xml" do
#   source "web/transitimeConfig.xml.erb"
#   owner 'tomcat7'
#   group 'tomcat7'
#   mode '0644'
# end
# # template transitime ocnfiguration
# template "/var/lib/oba/transitime/web/mysql_hibernate.cfg.xml" do
#   source "web/mysql_hibernate.cfg.xml.erb"
#   owner 'tomcat7'
#   group 'tomcat7'
#   mode '0644'
# end


%w{logback-classic-1.1.2.jar logback-core-1.1.2.jar slf4j-api-1.7.2.jar}.each do |jar_file|
  cookbook_file ["/usr/share/tomcat7/lib", jar_file].compact.join("/") do
    owner 'tomcat7'
    group 'tomcat7'
    source jar_file
    mode  '0444'
  end
end
script "deploy_web_pre" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  sudo service tomcat7 stop
  sudo rm -rf /var/lib/tomcat7/webapps/*
  sudo unzip #{mvn_web_dest_file} -d /var/lib/tomcat7/webapps/web || exit 1
  sudo unzip #{mvn_api_dest_file} -d /var/lib/tomcat7/webapps/api || exit 1
  sudo rm -f /var/lib/tomcat7/webapps/web/WEB-INF/classes/transiTimeConfig.xml
  sudo rm -f /var/lib/tomcat7/webapps/web/WEB-INF/classes/mysql_hibernate.cfg.xml
EOH
end

template "/var/lib/tomcat7/webapps/web/WEB-INF/classes/transiTimeConfig.xml" do
  source "web/transitimeConfig.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
# template transitime configuration
template "/var/lib/tomcat7/webapps/web/WEB-INF/classes/mysql_hibernate.cfg.xml" do
  source "web/mysql_hibernate.cfg.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
template "/var/lib/tomcat7/webapps/api/WEB-INF/classes/transiTimeConfig.xml" do
  source "web/transitimeConfig.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end
# template transitime configuration
template "/var/lib/tomcat7/webapps/api/WEB-INF/classes/mysql_hibernate.cfg.xml" do
  source "web/mysql_hibernate.cfg.xml.erb"
  owner 'tomcat7'
  group 'tomcat7'
  mode '0644'
end

script "deploy_web_post" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  sudo service tomcat7 start
EOH
end
