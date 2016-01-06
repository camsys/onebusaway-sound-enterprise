maintainer       "sheldonabrown"
maintainer_email "sheldonb@gmail.com"
license          "apachev2"
description      "Installs/Configures Tomcat and Apache and connects via mod_jk"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.14"
recipe           "tomcat-apache-mod-jk", "Installs Tomcat and Apache HTTP and connects mia mod_jk"
supports "ubuntu", ">= 10.04"

%w{ apache2 tomcat }.each do |cb|
  depends cb
end
