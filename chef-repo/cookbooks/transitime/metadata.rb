name             "transitime"
maintainer       "Sheldon A. Brown"
maintainer_email "sheldonb@gmail.com"
license          "Apache 2.0"
description      "Installs and Configures transitime prediction server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ java tomcat systemd }.each do |cb|
  depends cb
end

%w{ ubuntu debian }.each do |os|
  supports os
end

recipe "transitime::core", "Installs and Configures transitime prediction server"
recipe "transitime::web", "Installs and Configures transitime API and report server"
