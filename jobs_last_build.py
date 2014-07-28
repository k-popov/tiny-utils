#!/usr/bin/python -u
"""
The script prints out timestamp of last build for every job
found on Jenkins specified in argv[1]
"""
import requests
import simplejson
import sys
import logging

logging.basicConfig(level=logging.INFO)

jenkins_url = sys.argv[1]
json_api_suffix = "/api/json"

logging.info("getting list of jobs")
jobs_list = requests.get(
                        "%s/%s?tree=jobs[name,url]" % (jenkins_url, json_api_suffix)
                        ).json()
logging.info("got list of jobs")

for j in jobs_list["jobs"]:
    logging.info("processing job %s" % j["name"])
    try:
        lastbuilt = requests.get(
                                "%s/lastBuild%s?tree=timestamp" % (j["url"], json_api_suffix)
                                    ).json()["timestamp"]
    except simplejson.scanner.JSONDecodeError:
        lastbuilt = 0
    except Exception as e:
        raise e

    print("%s\t%s" % (j["name"], lastbuilt))
