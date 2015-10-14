name "transitime-web"
description "transitime web server"
run_list(
        "recipe[maven]",
        "recipe[tomcat]",
        "recipe[transitime::web]"
)
