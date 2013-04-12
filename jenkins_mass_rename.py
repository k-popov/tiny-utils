import os
import sys
import urllib2
import jenkinsapi
from jenkinsapi.jenkins import Jenkins
import jenkinsapi.config
import base64
import re

# Usage:
# export HUDSON_URL=https://__url_with_trailing_slash__/
# export HUDSON_USER=__user__
# export HUDSON_PASSWORD=__password__
# python __this_script__ "__view__" "__from_regex__" "__to_string__"
#
# parameters:
#    __view__: view containing all jobs that require renaming
#    __from_regex__: Regular expression to look for in job names
#    __to_string__: substitution in job name (use of back-references is possible, e.g. \1, \2, \3)

def rename(jenkins_url, jenkins_user, jenkins_password, job_name, new_job_name):
    url = jenkins_url + "job/" + job_name + "/doRename?newName=" + new_job_name
    req = urllib2.Request(url)

    auth = 'Basic ' + base64.urlsafe_b64encode("%s:%s" % (jenkins_user, jenkins_password))
    req.add_header('Authorization', auth)
    req.add_data("dummy") # switch to POST

    return urllib2.urlopen(req)

def disable(jenkins_url, jenkins_user, jenkins_password, job_name):
    url = jenkins_url + "job/" + job_name + "/disable"
    req = urllib2.Request(url)

    auth = 'Basic ' + base64.urlsafe_b64encode("%s:%s" % (jenkins_user, jenkins_password))
    req.add_header('Authorization', auth)
    req.add_data("dummy") # switch to POST

    return urllib2.urlopen(req)

def enable(jenkins_url, jenkins_user, jenkins_password, job_name):
    url = jenkins_url + "job/" + job_name + "/enable"
    req = urllib2.Request(url)

    auth = 'Basic ' + base64.urlsafe_b64encode("%s:%s" % (jenkins_user, jenkins_password))
    req.add_header('Authorization', auth)
    req.add_data("dummy") # switch to POST

    return urllib2.urlopen(req)

def main():

    # NOTE: trailing slash is significant
    jenkins_url = os.environ["HUDSON_URL"]
    api = Jenkins(
        jenkins_url,
        os.environ["HUDSON_USER"],
        os.environ["HUDSON_PASSWORD"]
    )

    view_of_jobs_to_rename = sys.argv[1]
    from_regex = sys.argv[2]
    to_substr = sys.argv[3]

    count = 0

    for job_name in api.get_view( view_of_jobs_to_rename ).get_job_dict():
        resp = None
        if not re.search(from_regex, job_name):
            print("Job name not matched", job_name)
            continue
        new_job_name = re.sub(from_regex, to_substr, job_name )
        try:
            resp = rename(
                jenkins_url,
                os.environ["HUDSON_USER"],
                os.environ["HUDSON_PASSWORD"],
                job_name,
                new_job_name
            )
        except urllib2.HTTPError as e:
            print( "FAILURE %s -> %s" % ( job_name, new_job_name) )
            print(e)
            sys.exit(1)

        count = count +1
        print count

    api = api._clone()

main()
