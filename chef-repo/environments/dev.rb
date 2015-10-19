require 'chef/data_bag'
name "dev"
description "environment attributes/configuration for dev environment"
default_attributes({
                       "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                           "mvn" => {
                               "group_id" => "org.onebusaway",
                               "version_nyc" => "2.10.0-st-SNAPSHOT",
                               "version_core" => "1.1.14-wmata.5-SNAPSHOT",
                               "version_app" => "1.1.14-wmata.5-SNAPSHOT",
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
                        "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/443046490497/obawmata_prod",
                        "sqsKey" => "AKIAJD2S6RVL5BB5VD6Q",
                        "sqsSecret" => "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",
                        "snsKey" => "AKIAJ34CZNNFNL5G2CUA",
                        "snsSecret" => "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",
                        "snsArn" => "arn:aws:sns:us-east-1:443046490497:wmata_avl"
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
