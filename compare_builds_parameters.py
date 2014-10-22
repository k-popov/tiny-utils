#!/usr/bin/env python

import requests
import sys
import difflib

PARAMS_API_SUFFIX = "api/json?tree=actions[parameters[name,value]]"

def slash(base_string):
    """ add a trailing slash if missing
    """
    if base_string[-1] != "/":
        return base_string + "/"
    return base_string

def list_from_dict(in_dict):
    """ create a list of KEY=VALUE of passed dict
    """
    out_list = []
    for key in sorted(in_dict.keys()):
        out_list.append("%s=%s" % (key, in_dict[key]))
    return out_list

if len(sys.argv) < 3 or sys.argv[1] == "--help":
    print "Usage: %s <build_url_1> <build_url_2:>"
    sys.exit(1)

build_params = [{} ,{}] # parameters will be stored here

for i in xrange(0, 2):
    params_json = requests.get(
        slash(sys.argv[i+1]) + PARAMS_API_SUFFIX
        ).json()

    for action in params_json['actions']:
        if action and 'parameters' in action:
            for param in action['parameters']:
                build_params[i][param['name']] = param['value']

#for build in build_params:
#    for l in list_from_dict(build):
#        print l

for line in difflib.unified_diff(
        list_from_dict(build_params[0]),
        list_from_dict(build_params[1])):
    print line
