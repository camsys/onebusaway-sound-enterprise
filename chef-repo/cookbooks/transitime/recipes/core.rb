mvn_version = node[:oba][:mvn][:version_transitime_web]
mvn_dest_file = "/tmp/transitimeCore-#{mvn_version}-onejar.jar"
log "maven dependency installed at #{mvn_dest_file}"
maven "transitimeCore" do
  group_id "transitime"
  dest "/tmp"
  version mvn_version
  packaging "jar"
  classifier "jar-with-dependencies"
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

## TODO
# ensure /Logs is present or mound /dev/vxdb as /Logs

script "install_broker" do
  interpreter "bash"
  user 'root'
  cwd "/var/lib/oba/transitime/core"
  puts "core version is #{mvn_version}"
  code <<-EOH
  mv #{mvn_dest_file} /var/lib/oba/transitime/core/core.jar || exit 1
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

service "predictions" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :stop => true, :start => true
  action [:start]
  only_if "test -f /etc/init/predictions.conf"
end
