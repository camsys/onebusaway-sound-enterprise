require 'chef/data_bag'
name "qa"
description "environment attributes/configuration for qa environment"
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
                       "db_instance" => "db",
                       "db_master" => "db.qa.wmata.obaweb.org",
                       "db_user" => "oba",
                       "db_password" => "changemeqa",
                       "env" => "qa",
                       "base_domain" => "wmata.obaweb.org",
                       "db_instance_name" => "org_onebusaway_users",
                       "db_agency" => "gtfsrt",
                       "db_archive" => "gtfsrt",
                       "api_server" => "app.qa.wmata.obaweb.org:8080",
                       "admin_server" => "admin.qa.wmata.obaweb.org",
                       "prediction_api_server" => "gtfsrt.qa.wmata.obaweb.org",
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
                         "dbhost" => "db.qa.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "transitime",
                         "dbpassword" => "transitimeqa",
                         "dbname" => "transitime",
                         "agency" => "1",
                         "api_key" => "qa3273b0",
                         "encryptionPassword" => "transitimeqa",
                         "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/443046490497/obawmata_prod",
                         "sqsKey" => "AKIAIAFMZDHCK3F55EIA",
                         "sqsSecret" => "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",
                         "snsKey" => "AKIAJ34CZNNFNL5G2CUA",
                         "snsSecret" => "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",
                         "snsArn" => "arn:aws:sns:us-east-1:443046490497:wmata_avl"
                       },
                      "aws" => {
                        "cloudwatch_publish_key" => "AKIAIHDQDZCGSQMYJAHQ",
                        "cloudwatch_publish_secret" => "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",
                        "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com",
                        "alarmCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Alarm-qa",
                        "alarmNonCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Monitoring-qa"
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
