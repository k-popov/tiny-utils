#!/usr/bin/env python

def tabify(data={}, first_level=True):
    """ Receives dict in the following format:
        {'nate.of.test.failed': [
            'http://url/to/failed/build',
            'http://url/to/another_failed/build',
            ]}
    first_level should not be set when calling, it's a flag for recursion
    Generates list of strings that if joined by "\\n" will give:
    failed.test.name
        http://url/to/failed/build
        http://url/to/another_failed/build

    and returns it.
    """
    result = []
    lvl_tab = "" if first_level else "\t"
    if isinstance(data, dict):
        for key, value in data.iteritems():
            result.append(lvl_tab + str(key))
            result.extend([lvl_tab + x for x in tabify(value, first_level=False)])
    elif isinstance(data, list) or isinstance(data, set):
        return ["\t" + str(x) for x in data]
    else:
        raise Exception(
            "data passed is {0}, neither dict nor list".format(type(data)))
    return result


print("\n".join(
    tabify(
        {'a':[1, 2, 3],
         'b': {
             'c': {
                 'x': ['y', 'z'],
                 'k': ['l', 'm']
                 },
             'd': set([4, 5, 6])
             },
         'e': [7, 8, 9]
        }))
     )
