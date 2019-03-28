name "transitime-shuttle-core"
description "transitime core prediction engine for shuttles"
run_list(
    "role[base]",
    "recipe[transitime::shuttle_core]"
)

override_attributes(
    :tz => 'America/New_York',
    :maven => {
        :m2_home => '/var/lib/maven'
    },
    :cw_mon => {
        :version => '1.2.1',
        :cron_min_freq => '3',
        :home_dir => '/var/lib/oba/monitoring',
        :user => 'ubuntu',
        :group => 'ubuntu',
        :options => %w{--mem-util --mem-used --mem-avail --disk-path=/ --disk-space-util --disk-space-used --disk-space-avail}
    }
)
