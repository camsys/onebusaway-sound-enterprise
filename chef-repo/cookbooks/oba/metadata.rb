name             "oba"
maintainer       "Sheldon A. Brown"
maintainer_email "sheldonb@gmail.com"
license          "Apache 2.0"
description      "Installs and Configures onebusaway components"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ java tomcat cloudwatch_monitoring }.each do |cb|
  depends cb
end

%w{ ubuntu debian }.each do |os|
  supports os
end

recipe "oba::app", "Installs and Configures oba enterprise webapp"
recipe "oba::admin", "Installs and Configures oba admin webapp"

