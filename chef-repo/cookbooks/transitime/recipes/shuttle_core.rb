###
# This is largely a duplicate of transitime "core" script
# this will be run in parallel of "core", and instead of risking
# additional parameterization we simply split it out
###

mvn_version = node[:oba][:mvn][:version_shuttle_transitime_core]
mvn_core_dest_file = "/tmp/chef/transitclockCore-#{mvn_version}-Core.jar"
log "maven dependency installed at #{mvn_core_dest_file}"
maven "transitclockCore" do
  group_id "TheTransitClock"
  dest "/tmp/chef/"
  version mvn_version
  packaging "jar"
  classifier "Core"
  owner "ubuntu"
  repositories node[:oba][:mvn][:repositories]
end

mvn_update_dest_file = "/tmp/chef/transitclockCore-#{mvn_version}-UpdateTravelTimes.jar"
log "maven dependency installed at #{mvn_update_dest_file}"
maven "transitclockCore" do
  group_id "TheTransitClock"
  dest "/tmp/chef/"
  version mvn_version
  packaging "jar"
  classifier "UpdateTravelTimes"
  owner "ubuntu"
  repositories node[:oba][:mvn][:repositories]
end


#systemd_service 'predictions' do
#  description 'Predictions Service'
#  after 'network.target'
#  service do
#    user node[:oba][:user]
#    exec_start "/var/lib/oba/transitime/core/core.sh"
#  end
#end

service 'predictions' do
  action [:enable]
end

service "predictions" do
  action [:stop]
end


directory "/var/lib/oba/transitime/core" do
  owner 'root'
  group 'root'
  action :create
  recursive true
end

directory "/var/lib/oba/transitime/logs" do
  owner 'ubuntu'
  group 'ubuntu'
  action :create
  recursive true
end

script "install_core" do
  interpreter "bash"
  user 'root'
  cwd "/var/lib/oba/transitime/core"
  puts "core version is #{mvn_version}"
  code <<-EOH
  mv #{mvn_core_dest_file} /var/lib/oba/transitime/core/core.jar || exit 1
  mv #{mvn_update_dest_file} /var/lib/oba/transitime/core/update.jar || exit 1
  EOH
end

template "/etc/systemd/system/predictions.service" do
  source "core/predictions.service.erb"
  owner "root"
  group "root"
  mode '0755'
end

template "/var/lib/oba/transitime/core/core.sh" do
  source "shuttle-core/core.sh.erb"
  owner "root"
  group "root"
  mode '0755'
end


# template transitime configuration
template "/var/lib/oba/transitime/core/mysql_hibernate.cfg.xml" do
  source "shuttle-core/mysql_hibernate.cfg.xml.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end

template "/var/lib/oba/transitime/core/ehcache.xml" do
  source "shuttle-core/ehcache.xml.erb"
  owner "root"
  group "root"
  mode '0755'
end


# template logback configuration
template "/var/lib/oba/transitime/core/logback.xml" do
  source "core/logback.xml.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end

service "predictions" do
  action [:start]
end

# monitoring directory
directory '/var/lib/oba/monitoring' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end
directory '/var/lib/oba/transitime/cache' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end
