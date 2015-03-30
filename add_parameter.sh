#!/bin/bash

# usage: ./add_permissions.sh "<job_url>" "<target_user>"

USERAUTH="<jenkins_admin>:<jenkins_admin_API_token>" # put your Jenkins token here
# do not forget to change it after you're done

JOB_URL="$1"
[ -z "$JOB_URL" ] && exit 1
PARAM_NAME="$2"
[ -z "$PARAM_NAME" ] && exit 1

[ -f temp_job_config.xml ] && { echo "temp_job_config.xml in current directory"; exit 2; }

JOB_URL=$(echo "$JOB_URL" | sed -e "s=^http://=http://${USERAUTH}@=" )
echo "${JOB_URL}"

curl --globoff "${JOB_URL}/config.xml" > temp_job_config.xml
sed -i -e "s@<parameterDefinitions>@<parameterDefinitions>\n<hudson.model.StringParameterDefinition>\n<name>$PARAM_NAME</name>\n<description></description>\n<defaultValue></defaultValue>\n</hudson.model.StringParameterDefinition>@" temp_job_config.xml
curl --fail -X POST -H "Content-Type: text/xml" --globoff --data-binary @temp_job_config.xml "${JOB_URL}/config.xml" || exit $?

rm temp_job_config.xml
