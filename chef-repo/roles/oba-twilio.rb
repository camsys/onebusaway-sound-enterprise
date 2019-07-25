name "oba-twilio"
description "oba twilio tomcat install"
run_list(
    "recipe[maven]",
    "recipe[oba::twilio]"
)

override_attributes(
    :tz => 'America/New_York',
    :maven => {
        :m2_home => '/var/lib/maven'
    },
    :tomcat => {
        :java_options => '-Xmx1G -Xms256m -XX:MaxPermSize=756m -Djava.awt.headless=true -XX:+UseConcMarkSweepGC'
    }
)
