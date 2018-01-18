#!/usr/bin/env python
# -*- coding: utf8 -*-
# 1un
# 2018-01-17

import json


urlfile = '/monitor/web/url.txt'
jsonurls = dict(data=list())

with open(urlfile, 'r') as f:
    for line in f.readlines():
        l = line.strip()

        if l and (not l.startswith('#')):
            t = tuple(l.split(','))
            tuple_dict = {
                '{#SITEURL}': t[1],
                '{#WEBRETURN}': t[2]
            }

            jsonurls['data'].append(tuple_dict)

result = json.dumps(jsonurls, sort_keys=True, indent=4, encoding='utf8')

print(result)
