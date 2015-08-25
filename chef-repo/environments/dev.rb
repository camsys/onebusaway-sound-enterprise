require 'chef/data_bag'
name "dev"
description "environment attributes/configuration for dev environment"
default_attributes({
                       "oba" => {
                       "user" => "dev",
                       "home" => "/home/dev",
                           "mvn" => {
                               "version_nyc" => "2.10.0-st-SNAPSHOT",
                               "version_core" => "1.1.13-st.3",
                               "version_transitime_core" => "0.0.2-SNAPSHOT",
                               "version_transitime_web" => "0.0.2-SNAPSHOT",
                               "repositories" => ["http://developer.onebusaway.org/archiva/repository/snapshots/"]

                       },
                       "transitime" => {
                         "dbhost" => "db.dev.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "prediction",
                         "dbpassword" => "changeme",
                         "dbname" => "transitime",
                         "agency" => "1",
                       }
                     },
                     "tomcat" => {
                       "user" => "tomcat7",
                       "group" => "tomcat7",
                       "base_version" => "7"
                     },
                     "java" => {
                       "jdk_version" => "7"
                     }
                   })
