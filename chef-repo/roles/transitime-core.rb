name "transitime-core"
description "transitime core prediction engine"
run_list(
        "recipe[maven]",
        "recipe[transitime::core]"
)

override_attributes(:maven => {
                      :m2_home => '/var/lib/maven'
                    }
)
