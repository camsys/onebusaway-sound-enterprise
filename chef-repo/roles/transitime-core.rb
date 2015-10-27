name "transitime-core"
description "transitime core prediction engine"
run_list(
        "role[base]",
        "recipe[transitime::core]"
)

override_attributes(
                    :tz => 'America/New_York',
                    :maven => {
                      :m2_home => '/var/lib/maven'
                    }
)
