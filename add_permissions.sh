#!/bin/bash

# usage: ./add_permissions.sh "<job_url>" "<target_user>"

USERAUTH="<jenkins_admin>:<jenkins_admin_API_token>" # put your Jenkins token here
# do not forget to change it after you're done

JOB_URL="$1"
[ -z "$JOB_URL" ] && exit 1
TARGET_USER="$2"
[ -z "$TARGET_USER" ] && exit 1

[ -f temp_job_config.xml ] && { echo "temp_job_config.xml in current directory"; exit 2; }

JOB_URL=$(echo "$JOB_URL" | sed -e "s=^http://=http://${USERAUTH}@=" )
echo "${JOB_URL}"

curl --globoff "${JOB_URL}/config.xml" > temp_job_config.xml
sed -i -e "s@<hudson.security.AuthorizationMatrixProperty>@<hudson.security.AuthorizationMatrixProperty>\n<permission>hudson.model.Item.Build:${TARGET_USER}</permission>@" temp_job_config.xml
sed -i -e "s@<hudson.security.AuthorizationMatrixProperty>@<hudson.security.AuthorizationMatrixProperty>\n<permission>hudson.model.Item.Read:${TARGET_USER}</permission>@" temp_job_config.xml
curl --fail -X POST -H "Content-Type: text/xml" --globoff --data-binary @temp_job_config.xml "${JOB_URL}/config.xml" || exit $?

rm temp_job_config.xml
