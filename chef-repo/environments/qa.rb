require 'chef/data_bag'
name "qa"
description "environment attributes/configuration for qa environment"
default_attributes({
                     "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                       "mvn" => {
                           "group_id" => "org.onebusaway",
                           "version_admin" => "2.0.15-cs",
                           "version_core" => "2.0.15-cs",
                           "version_app" => "2.0.15-cs",
                           "version_branded" => "2.0.15-cs",
                           "version_transitime_core" => "0.0.39",
                           "version_transitime_web" => "0.0.39",
                           "version_shuttle_transitime_core" => "0.0.39",
                           "version_shuttle_transitime_web" => "0.0.39",
                           "repositories" => ["http://repo.obaweb.org:8080/archiva/repository/releases/"]
                       },
                       "db_instance" => "db",
                       "db_master" => "db.qa.wmata.obaweb.org",
                       "db_user" => "oba",
                       "db_password" => "changeme",
                       "env" => "qa",
                       "base_domain" => "wmata.obaweb.org",
                       "db_instance_name" => "org_onebusaway_users",
                       "db_agency" => "gtfsrt",
                       "db_archive" => "gtfsrt",
                       "api_server" => "app.qa.wmata.obaweb.org",
                       "admin_server" => "admin.qa.wmata.obaweb.org",
                       "prediction_api_server" => "gtfsrt.qa.wmata.obaweb.org",
                       "prediction_api_port" => "8080",
                       "admin_server_port" => "8080",
                       "tds" => {
                         "bundle_path" => "/var/lib/oba/bundle"
                       },
                       "webapp" => {
                         "artifact" => "onebusaway-enterprise-wmata-webapp"
                       },
		       "wmata_webapp" => {
                          "artifact" => "onebusaway-enterprise-wmata-webapp"
                       },
                       "hart_webapp" => {
                          "artifact" => "onebusaway-enterprise-hart-webapp"
                       },
                       "sound_webapp" => {
                          "artifact" => "onebusaway-enterprise-sound-webapp"
                       },
                       "ses_host" => "email-smtp.us-east-1.amazonaws.com",
                       "ses_user" => "AKIAISKUXW2UHBZRHHNA",
                       "ses_password" => "AhxzNCmnlqzK8qjPwsQ41yHUbk3meOlHZvVRuoVoM7/t",
                       "ses_from" => "btss@wmata.com",
                       "mobile_require_ssl" => "true",
		       "tomcat" => {
                           "instance_name" => "tomcat8"
                       }
                     },
                       "transitime" => {
                         "dbhost" => "db.qa.wmata.obaweb.org:3306",
                         "dbrohost" => "db-ro.qa.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "transitime",
                         "dbpassword" => "transitimeprod",
                         "dbname" => "transitime",
                         "agency" => "1",
                         "api_key" => "prod3273b0",
                         "encryptionPassword" => "transitimeprod",
                         "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/372394388595/obawmata_qa",
                         "sqsKey" => "AKIAIAFMZDHCK3F55EIA",
                         "sqsSecret" => "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",
                         "snsKey" => "",
                         "snsSecret" => "",
                         "snsArn" => "",
                         "retentionDays" => "90"
                       },
                     "shuttle" => {
                         "dbhost" => "db.qa.wmata.obaweb.org:3306",
                         "dbrohost" => "db-ro.qa.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "shuttle",
                         "dbpassword" => "changeme",
                         "dbname" => "dash_transitime",
                         "agency" => "71",
                         "api_key" => "612bek1",
                         "encryptionPassword" => "dash_transitime",
                         "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/443046490497/obadash_prod",
                         "sqsKey" => "AKIAWOJ5A6GA3NR35E2S",
                         "sqsSecret" => "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",
                         "snsKey" => "AKIAJ34CZNNFNL5G2CUA",
                         "snsSecret" => "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",
                         "snsArn" => "arn:aws:sns:us-east-1:443046490497:dash_avl",
                         "retentionDays" => "30",
                         "env" => "dash_shuttle_qa"
                     },
                     "aws" => {
                        "cloudwatch_publish_key" => "AKIAIHDQDZCGSQMYJAHQ",
                        "cloudwatch_publish_secret" => "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",
                        "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com",
                        "alarmCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Alarm-qa",
                        "alarmNonCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Monitoring-qa"
                       },
                     "tomcat" => {
                       "user" => "tomcat_user",
                       "group" => "tomcat_group",
                       "base_version" => "8"
                     },
                     "java" => {
                       "jdk_version" => "8"
                     },
                     "apache" => {
                        "proxy" => {
                          "require" => "all granted"
                        }
                     }
                   })
