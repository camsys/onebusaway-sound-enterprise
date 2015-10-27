name "transitime-web"
description "transitime web server"
run_list(
        "role[base]",
        "recipe[tomcat]",
        "recipe[transitime::web]"
)
override_attributes(
                    :tz => 'America/New_York'
)
