name "transitime-web"
description "transitime web server"
run_list(
        "recipe[maven]",
        "recipe[tomcat]",
        "recipe[transitime::web]"
)

override_attributes(:maven => {
                      :m2_home => '/var/lib/maven'
                    },
                    :tomcat => {
                      :java_options => '-Xmx3G -Xms1G -XX:MaxPermSize=256m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Dtransitime.rmi.timeoutSec=300 -Dtransitime.db.encryptionPassword=transitimeqa'
                    }
)
