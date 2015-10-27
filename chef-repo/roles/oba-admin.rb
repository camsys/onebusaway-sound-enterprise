name "oba-admin"
description "oba admin server"
run_list(
        "role[base]",
        "recipe[tomcat]",
        "recipe[oba::admin]"
)

override_attributes(
                    :tz => 'America/New_York',
                    :maven => {
                      :m2_home => '/var/lib/maven'
                    },
                    :tomcat => {
                      :java_options => '-Xmx3G -Xms1G -XX:MaxPermSize=256m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC'
                    }
)
