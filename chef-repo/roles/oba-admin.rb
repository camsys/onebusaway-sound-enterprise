name "oba-admin"
description "oba admin server"
run_list(
        "recipe[maven]",
        "recipe[tomcat]",
        "recipe[oba::admin]"
)

override_attributes(:maven => {
                      :m2_home => '/var/lib/maven'
                    },
                    :tomcat => {
                      :java_options => '-Xmx3G -Xms1G -XX:MaxPermSize=256m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC',
                      :instances => {
                        :watchdog => {
                          'port' => 7070,
                          'proxy_port' => nil,
                          'ssl_port' => 7443,
                          'ssl_proyx_port' => nil,
                          'ajp_port' => 7009,
                          'shutdown_port' => 7005,
                          'config_dir' => '/etc/watchdog',
                          'log_dir' => '/var/log/watchdog',
                          'work_dir' => '/var/cache/watchdog/work',
                          'context_dir' => "/etc/watchdog/Catalina/localhost",
                          'webapp_dir' => "/var/lib/watchdog/webapps",
                          'catalina_options' => '',
                          'java_options' => "-Xmx128M -Djava.awt.headless=true",
                          'use_security_manager' => false,
                          'authbind' => 'no',
                          'max_threads' => nil,
                          'ssl_max_threads' => 150,
                          'ssl_cert_file' => nil,
                          'ssl_key_file' => nil,
                          'ssl_chain_files' => nil,
                          'keystore_file' => 'keystore.jks',
                          'keystore_type' => 'jks',
                          'certificate_dn' => "cn=localhost",
                          'loglevel' => "INFO",
                          'tomcat_auth' => "true",
                          'user' => "tomcat",
                          'group' => "tomat",
                          'home' => "/var/lib/watchdog",
                          'base' => "/var/lib/watchdog",
                          'tmp_dir' => "/var/cache/watchdog/temp",
                          'lib_dir' => "/var/lib/watchdog/lib",
                          'endorsed_dir' => "/var/lib/watchdog/lib/endorsed"
                        }
                      }
                    }
)
