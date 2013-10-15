#!/bin/sh

# $1 is a JSON file. It will be printed in a nice, indented form

python -c "import simplejson; f = open('$1', 'r'); print simplejson.dumps(simplejson.loads(f.read()), indent=2); f.close()"
