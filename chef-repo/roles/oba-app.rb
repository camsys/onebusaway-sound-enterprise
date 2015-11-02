name "oba-app"
description "oba app/front-end server"
run_list(
        "role[base]",
        "recipe[tomcat]",
        "recipe[oba::app]",
        "recipe[cloudwatch_monitoring]"
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
                      :home_dir => '/var/lib/oba/monitoring/aws-scripts-mon',
                      :user => 'ubuntu',
                      :group => 'ubuntu',
                      :options => '/var/lib/oba/monitoring/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-path=/ --disk-space-util --disk-space-used --disk-space-avail'
                    }
)
