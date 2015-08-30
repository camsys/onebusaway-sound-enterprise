name "oba-app"
description "oba app/front-end server"
run_list(
        "recipe[maven]",
        "recipe[tomcat]",
        "recipe[oba::app]"
)

override_attributes(:maven => {
                      :m2_home => '/var/lib/maven'
                    },
                    :tomcat => {
                      :java_options => '-Xmx3G -Xms1G -XX:MaxPermSize=256m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC'
                    }
)
