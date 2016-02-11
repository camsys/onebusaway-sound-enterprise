mvn_version = node[:oba][:mvn][:version_transitime_web]
mvn_core_dest_file = "/tmp/chef/transitimeCore-#{mvn_version}-onejar.jar"
log "maven dependency installed at #{mvn_core_dest_file}"
maven "transitimeCore" do
  group_id "transitime"
  dest "/tmp/chef/"
  version mvn_version
  packaging "jar"
  classifier "onejar"
  owner "ubuntu"
  repositories node[:oba][:mvn][:repositories]
end

mvn_update_dest_file = "/tmp/chef/transitimeCore-#{mvn_version}-UpdateTravelTimes.jar"
log "maven dependency installed at #{mvn_update_dest_file}"
maven "transitimeCore" do
  group_id "transitime"
  dest "/tmp/chef/"
  version mvn_version
  packaging "jar"
  classifier "UpdateTravelTimes"
  owner "ubuntu"
  repositories node[:oba][:mvn][:repositories]
end


service "predictions" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :stop => true, :start => true
  action [:stop]
  only_if "test -f /etc/init/predictions.conf"
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

## TODO
# ensure /Logs is present or mound /dev/vxdb as /Logs

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

template "/etc/init/predictions.conf" do
    source "core/predictions.conf.erb"
    owner "root"
    group "root"
    mode '0755'
end

template "/var/lib/oba/transitime/core/core.sh" do
    source "core/core.sh.erb"
    owner "root"
    group "root"
    mode '0755'
end
template "/var/lib/oba/transitime/core/update.sh" do
    source "core/update.sh.erb"
    owner "root"
    group "root"
    mode '0755'
end
template "/var/lib/oba/transitime/core/update_batch.sh" do
    source "core/update_batch.sh.erb"
    owner "root"
    group "root"
    mode '0755'
end
template "/var/lib/oba/transitime/core/daily_maintenance.sh" do
    source "core/daily_maintenance.sh.erb"
    owner "root"
    group "root"
    mode '0755'
end
["predictions", "avlreports", "arrivalsdepartures"].each do |script|
  template "/var/lib/oba/transitime/core/vacuum_#{script}" do
    source "core/vacuum_#{script}.sql.erb"
    owner "root"
    group "root"
    mode '0644'
  end
end
# template transitime configuration
template "/var/lib/oba/transitime/core/mysql_hibernate.cfg.xml" do
  source "core/mysql_hibernate.cfg.xml.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end
# template logback configuration
template "/var/lib/oba/transitime/core/logback.xml" do
  source "core/logback.xml.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end
service "predictions" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :stop => true, :start => true
  action [:start]
  only_if "test -f /etc/init/predictions.conf"
end

# monitoring directory
directory '/var/lib/oba/monitoring' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

cron "daily-maintenance" do
  hour "1"
  minute "0"
  logfile = "/var/lib/oba/transitime/logs/daily_cron.log"
  command "cd /var/lib/oba/transitime/core && ./daily_maintenance.sh >> #{logfile} 2>&1"
  user "ubuntu"
end
