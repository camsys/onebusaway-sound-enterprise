require 'chef/data_bag'
name "dev"
description "environment attributes/configuration for dev environment"
default_attributes({
                     "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                       "mvn" => {
                           "group_id" => "org.onebusaway",
                           "version_admin" => "1.1.15.24-cs-SNAPSHOT",
                           "version_core" => "1.1.15.24-cs-SNAPSHOT",
                           "version_app" => "1.1.15.24-cs-SNAPSHOT",
                           "version_branded" => "1.1.15.24-cs-SNAPSHOT",
                           "version_transitime_core" => "0.0.24-SNAPSHOT",
                           "version_transitime_web" => "0.0.24-SNAPSHOT",
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
                       },
                       "archiva" => {
                           "s3_user" =>  "AKIAJGPEIERX2KIPI52A",
                           "s3_password" => "qOhfseblnczHLlWpFvqwp8KFxAXUWzgK6P7xAlz9"
                       },
                       "ses_host" => "email-smtp.us-east-1.amazonaws.com",
                       "ses_user" => "AKIAISKUXW2UHBZRHHNA",
                       "ses_password" => "AhxzNCmnlqzK8qjPwsQ41yHUbk3meOlHZvVRuoVoM7/t",
                       "ses_from" => "btss@wmata.com"
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
                        "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/744689548994/obawmata_dev",
                        "sqsKey" => "AKIAIR7AIWS2STDBINAQ",
                        "sqsSecret" => "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",
                        "snsKey" => "",
                        "snsSecret" => "",
                        "snsArn" => "",
                        "retentionDays" => "30"
                      },
                     "aws" => {
                       "cloudwatch_publish_key" => "AKIAJ2USYJ54JLTDL6CA",
                       "cloudwatch_publish_secret" => "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",
                       "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com",
                       "alarmCriticalSns" => "arn:aws:sns:us-east-1:744689548994:OBAWMATA-Alarm-dev",
                       "alarmNonCriticalSns" => "arn:aws:sns:us-east-1:744689548994:OBAWMATA-Monitoring-dev"
                     },
                     "tomcat" => {
                       "user" => "tomcat7",
                       "group" => "tomcat7",
                       "base_version" => "7"
                     },
                     "java" => {
                       "jdk_version" => "7"
                     },
                     "apache" => {
                        "proxy" => {
                          "require" => "all granted"
                        }
                     }
                   })
