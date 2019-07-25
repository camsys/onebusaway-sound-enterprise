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
)
