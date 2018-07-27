name "base"
description "The base role for all OBA servers"
run_list(
        "recipe[java]",
        "recipe[maven]",
        "recipe[timezone-ii]",
        "recipe[ntp]"
)
