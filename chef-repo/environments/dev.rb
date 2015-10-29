require 'chef/data_bag'
name "dev"
description "environment attributes/configuration for dev environment"
default_attributes({
                       "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                           "mvn" => {
                               "group_id" => "org.onebusaway",
                               "version_admin" => "1.1.15-cs-SNAPSHOT",
                               "version_core" => "1.1.15-cs-SNAPSHOT",
                               "version_app" => "1.1.15-cs-SNAPSHOT",
                               "version_transitime_core" => "0.0.2-SNAPSHOT",
                               "version_transitime_web" => "0.0.2-SNAPSHOT",
                               "repositories" => ["http://developer.onebusaway.org/archiva/repository/snapshots/"]

                       },
                       "db_master" => "db.dev.wmata.obaweb.org",
                       "db_user" => "oba",
                       "db_password" => "changeme",
                       "env" => "dev",
                       "base_domain" => "wmata.obaweb.org",
                       "db_instance_name" => "org_onebusaway_users",
                       "db_agency" => "gtfsrt",
                       "db_archive" => "gtfsrt",
                       "api_server" => "app.dev.wmata.obaweb.org:8080",
                       "admin_server" => "admin.dev.wmata.obaweb.org",
                       "prediction_api_server" => "gtfsrt.dev.wmata.obaweb.org",
                       "prediction_api_port" => "8080",

                       "admin_server_port" => "8080",
                       "tds" => {
                         "bundle_path" => "/var/lib/oba/bundle"
                       },
                       "webapp" => {
                         "artifact" => "onebusaway-enterprise-acta-webapp"
                       }
                     },
                     "transitime" => {
                        "dbhost" => "db.dev.wmata.obaweb.org:3306",
                        "dbtype" => "mysql",
                        "dbusername" => "prediction",
                        "dbpassword" => "changeme",
                        "dbname" => "transitime",
                        "agency" => "1",
                        "api_key" => "4b248c1b",
                        "encryptionPassword" => "SET THIS!",
                        "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/744689548994/obawmata_dev",
                        "sqsKey" => "AKIAIR7AIWS2STDBINAQ",
                        "sqsSecret" => "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",
                        "snsKey" => "",
                        "snsSecret" => "",
                        "snsArn" => ""
                      },
                     "aws" => {
                       "cloudwatch_publish_key" => "AKIAJ2USYJ54JLTDL6CA",
                       "cloudwatch_publish_secret" => "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",
                       "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com"
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
