name "base"
description "The base role for all OBA servers"
run_list(
        "recipe[maven]",
        "recipe[timezone]",
        "recipe[ntp]"
)
