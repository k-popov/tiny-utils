#!/usr/bin/python -u
"""
The scripts acts like GNU grep but iterates over Jenkins jobs.
String to serch is passed as argv[1]
Jenkins base URL is passed as argv[2]
Jenkins user name is to be set in JENKINS_USER env variable
Jenkins user token is to be set in JENKINS_TOKEN env variable
"""

import requests
import simplejson
import sys
import logging
import os

logging.basicConfig(level=logging.INFO)

search_string = sys.argv[1]
jenkins_url = sys.argv[2]
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
    logging.info("processing job %s" % j["name"])
    try:
        configtext = requests.get(
            "/".join([jenkins_authed_url, 'job', j["name"], 'config.xml'])
            ).text
    except Exception as e:
        raise e
    if search_string in configtext:
        print("%s" % (j["name"]))
