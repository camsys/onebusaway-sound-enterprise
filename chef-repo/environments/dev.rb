require 'chef/data_bag'
name "dev"
description "environment attributes/configuration for dev environment"
default_attributes({
                     "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                       "mvn" => {
                           "group_id" => "org.onebusaway",
                           "version_admin" => "2.0.41-cs-SNAPSHOT",
                           "version_twilio" => "2.0.41-cs-SNAPSHOT",
                           "version_core" => "2.0.41-cs-SNAPSHOT",
                           "version_app" => "2.0.41-cs-SNAPSHOT",
                           "version_branded" => "2.0.41-cs-SNAPSHOT",
                           "version_transitime_core" => "0.0.42-SNAPSHOT",
                           "version_transitime_web" => "0.0.42-SNAPSHOT",
                           "version_shuttle_transitime_core" => "0.0.42-SNAPSHOT",
                           "version_shuttle_transitime_web" => "0.0.42-SNAPSHOT",
                           "repositories" => ["http://repo.obaweb.org:8080/archiva/repository/snapshots/"]
                       },
                       "db_instance" => "db",  
                       "db_master" => "db.dev.wmata.obaweb.org",
                       "db_user" => "oba",
                       "db_password" => "changeme",
                       "env" => "dev",
                       "base_domain" => "wmata.obaweb.org",
                       "db_instance_name" => "org_onebusaway_users",
                       "db_agency" => "gtfsrt",
                       "db_archive" => "gtfsrt",
                       "api_server" => "app.dev.wmata.obaweb.org",
                       "admin_server" => "admin.dev.wmata.obaweb.org",
                       "prediction_api_server" => "gtfsrt.dev.wmata.obaweb.org",
                       "prediction_api_port" => "8080",
                       "admin_server_port" => "8080",
                       "tds" => {
                          "bundle_path" => "/var/lib/oba/bundle"
                       },
                       "webapp" => {
                          "artifact" => "onebusaway-enterprise-acta-webapp"
                       },
                       "wmata_webapp" => {
                          "artifact" => "onebusaway-enterprise-wmata-webapp"
                       },
                       "hart_webapp" => {
                          "artifact" => "onebusaway-enterprise-hart-webapp"
                       },
                       "dash_webapp" => {
                           "artifact" => "onebusaway-enterprise-dash-webapp"
                       },
                       "sound_webapp" => {
                          "artifact" => "onebusaway-enterprise-sound-webapp"
                       },
                       "archiva" => {
                           "s3_user" =>  "AKIAJGPEIERX2KIPI52A",
                           "s3_password" => "qOhfseblnczHLlWpFvqwp8KFxAXUWzgK6P7xAlz9"
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
                        "dbhost" => "db.dev.wmata.obaweb.org:3306",
                        "dbrohost" => "db-ro.dev.wmata.obaweb.org:3306",
                        "dbtype" => "mysql",
                        "dbusername" => "prediction",
                        "dbpassword" => "changeme",
                        "dbname" => "transitime",
                        "agency" => "1",
                        "api_key" => "4b248c1b",
                        "encryptionPassword" => "SET THIS!",
                        "#sqsUrl" => "https://sqs.us-east-1.amazonaws.com/744689548994/obawmata_dev",
                        "#sqsKey" => "AKIAIR7AIWS2STDBINAQ",
                        "#sqsSecret" => "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",
                        "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/372394388595/obawmata_qa",
                        "sqsKey" => "AKIAIAFMZDHCK3F55EIA",
                        "sqsSecret" => "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",
                        "snsKey" => "",
                        "snsSecret" => "",
                        "snsArn" => "",
                        "retentionDays" => "30"
                      },
                     "shuttle" => {
                         "dbhost" => "db.dev.wmata.obaweb.org:3306",
                         "dbrohost" => "db-ro.dev.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "shuttle",
                         "dbpassword" => "changeme",
                         "dbname" => "dash_transitime",
                         "agency" => "71",
                         "api_key" => "612bek1",
                         "encryptionPassword" => "dash_transitime",
                         "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/744689548994/obadash_avl",
                         "sqsKey" => "AKIA22YXUX3BBTD6KCCM",
                         "sqsSecret" => "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",
                         "snsKey" => "",
                         "snsSecret" => "",
                         "snsArn" => "",
                         "retentionDays" => "30",
                         "env" => "dash_shuttle_dev"
                     },

                     "aws" => {
                       "cloudwatch_publish_key" => "AKIAJ2USYJ54JLTDL6CA",
                       "cloudwatch_publish_secret" => "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",
                       "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com",
                       "alarmCriticalSns" => "arn:aws:sns:us-east-1:744689548994:OBAWMATA-Alarm-dev",
                       "alarmNonCriticalSns" => "arn:aws:sns:us-east-1:744689548994:OBAWMATA-Monitoring-dev"
                     },
                     "tomcat" => {
                       "user" => "tomcat_user",
                       "group" => "tomcat_group",
                       "base_version" => "8",
                       "version" => "8.0.53"
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
