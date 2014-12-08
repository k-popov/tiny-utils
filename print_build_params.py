#!/usr/bin/env python

""" Usage: pythoon print_build_params.py <jenkins_build_url>
"""

import requests
import sys

if len(sys.argv) < 2:
    raise Exception("Not enough parameters. See usage docstring.")

build_url = sys.argv[1]
build_data = requests.get(
    build_url + '/api/json?tree=actions[parameters[name,value]]').json()
# extract parameters data
parameters_data = [x for x in build_data['actions'] if x][0]['parameters']
for p in parameters_data:
    print("{0}={1}".format(p['name'], p['value']))

sys.exit(0)
