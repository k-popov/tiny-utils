#!/usr/bin/python -u
"""
The scripts acts like GNU grep but iterates over Jenkins jobs.
String to serch is passed as argv[1]. It is treated like RegEx
Jenkins base URL is passed as argv[2]
Regex for jobs filtering (by name) is passed as argv[3] (may be empty)
Jenkins user name is to be set in JENKINS_USER env variable
Jenkins user token is to be set in JENKINS_TOKEN env variable
"""

import requests
import sys
import logging
import os
import re

logging.basicConfig(level=logging.INFO)

search_regex = sys.argv[1]
jenkins_url = sys.argv[2]
name_filter = sys.argv[3]
json_api_suffix = "/api/json"

jenkins_user = os.environ.get("JENKINS_USER", None)
jenkins_token = os.environ.get("JENKINS_TOKEN", None)
if not (jenkins_user and jenkins_token):
    raise Exception("JENKINS_USER or JENKINS_TOKEN is not set")

jenkins_authed_url = (jenkins_url.split('://')[0] + '://' +
                      jenkins_user + ':' + jenkins_token + '@' +
                      '://'.join(jenkins_url.split('://')[1:])
                      )

logging.info("getting list of jobs")
jobs_list = requests.get(
    "%s/%s?tree=jobs[name]" % (jenkins_authed_url, json_api_suffix)
    ).json()
logging.info("got list of jobs")

for j in jobs_list["jobs"]:
    if name_filter and (not re.search(name_filter, j["name"])):
        logging.info("Skipping job %s as it is not matching filter regex",
                     j["name"])
        continue
    logging.info("Processing job %s" % j["name"])
    try:
        configtext = requests.get(
            "/".join([jenkins_authed_url, 'job', j["name"], 'config.xml'])
            ).text
    except Exception as e:
        raise e
    if re.search(search_regex, configtext):
        print("%s" % (j["name"]))
