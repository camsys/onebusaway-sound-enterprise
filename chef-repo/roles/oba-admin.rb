name "oba-admin"
description "oba admin server"
run_list(
        "role[base]",
        "recipe[tomcat]",
        "recipe[oba::admin]",
        "recipe[transitime::gtfs]"
)

override_attributes(
                    :tz => 'America/New_York',
                    :maven => {
                      :m2_home => '/var/lib/maven'
                    },
                    :tomcat => {
                      :java_options => '-Xmx3G -Xms1G -XX:MaxPermSize=256m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC'
                    },
                    :cw_mon => {
                      :version => '1.2.1',
                      :cron_min_freq => '3',
                      :home_dir => '/var/lib/oba/monitoring',
                      :user => 'ubuntu',
                      :group => 'ubuntu',
                      :options => %w{--mem-util --mem-used --mem-avail --disk-path=/ --disk-space-util --disk-space-used --disk-space-avail}
                    }
)
