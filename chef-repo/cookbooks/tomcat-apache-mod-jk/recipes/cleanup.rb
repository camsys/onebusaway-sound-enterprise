script "cleanup" do
  interpreter "bash"
  user "root"
  cwd node[:oba][:home]
  code <<-EOH
  if [ -f "/etc/apache2/mods-enabled/jk.conf" ]; then
    sudo rm "/etc/apache2/mods-enabled/jk.conf"
  fi
  EOH
end
