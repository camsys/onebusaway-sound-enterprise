###
# This is largely a duplicate of transitime "gtfs" script
# this will be run in parallel of "gtfs", and instead of risking
# additional parameterization we simply split it out
###

mvn_version = node[:oba][:mvn][:version_shuttle_transitime_core]
mvn_dest_file = "/tmp/chef/transitimeCore-#{mvn_version}-GtfsFileProcessor.jar"
log "maven dependency installed at #{mvn_dest_file}"
maven "transitimeCore" do
  group_id "transitime"
  dest "/tmp/chef"
  version mvn_version
  packaging "jar"
  classifier "GtfsFileProcessor"
  owner "ubuntu"
  repositories node[:oba][:mvn][:repositories]
end

directory "/var/lib/oba/transitime/processGTFS" do
  owner 'ubuntu'
  group 'ubuntu'
  action :create
  recursive true
end

directory "/var/lib/oba/transitime/gtfs" do
  owner 'ubuntu'
  group 'ubuntu'
  action :create
  recursive true
end

directory "/Logs" do
  owner 'ubuntu'
  group 'ubuntu'
  action :create
  recursive true
end

script "install_broker" do
  interpreter "bash"
  user 'root'
  cwd "/var/lib/oba/transitime/processGTFS"
  puts "core version is #{mvn_version}"
  code <<-EOH
  mv #{mvn_dest_file} /var/lib/oba/transitime/processGTFS/GtfsFileProcessor.jar || exit 1
  EOH
end

# template transitime configuration
template "/var/lib/oba/transitime/processGTFS/mysql_hibernate.cfg.xml" do
  source "shuttle-core/mysql_hibernate.cfg.xml.erb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end

["processGTFS", "get", "update", "swap"].each do |file|
  template "/var/lib/oba/transitime/processGTFS/#{file}.sh" do
    source "gtfs/#{file}.sh.erb"
    owner "root"
    group "root"
    mode '0755'
  end
end

# monitoring directory
directory '/var/lib/oba/monitoring' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

