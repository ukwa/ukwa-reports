---
jupytext:
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.15.2
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

+++ {"editable": true, "slideshow": {"slide_type": ""}}

# Recent CDX Indexed WARCs

This page shows recent WARCs and their CDX-indexing status. The last month's worth of data is shown, and any WARCs that are known to the tracking database, but not yet CDX indexed, will be marked as `missing`.

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
import json
import requests
import pandas as pd
from ukwa_reports.solr_facet_helper import flatten_solr_buckets

headers = {'content-type': "application/json" }

json_facet = {
    # Primary facet is by date - here we break down the last month(s) into days
    'facet': {
        'dates' : { 
            'type' : 'range', 
            'field' : 'timestamp_dt', 
            'start' : "NOW/MONTH-1MONTH",
            'end' : "NOW/MONTH+32DAY", 
#            'start' : "NOW/MONTH-10YEAR",
#            'end' : "NOW/MONTH+1MONTH", 
            'gap' : "+1DAY", 
#            'gap' : "+1MONTH", 
            # For each day, we facet:
            'facet': { 
                'stream': { 
                    'type': 'terms', 
                    "field": "stream_s", 
                    'missing': True,
                    'facet': { 
                        'cdx_status': { 
                            'type': 'terms', 
                            "field": "cdx_index_ss", 
                            'missing': True,
                            'facet' : {
                                'bytes': 'sum(file_size_l)'
                            }
                        }
                    }
                }
            }
        } 
    }
}


params = {
  'q': 'kind_s:"warcs"',
  'rows': 0
}

r = requests.post("http://solr8.api.wa.bl.uk/solr/tracking/select", params=params, data=json.dumps(json_facet), headers=headers)

if r.status_code != 200:
    print(r.text)

df = pd.DataFrame(flatten_solr_buckets(r.json()['facets']))
# Filter empty rows:
df=df[df['count'] != 0]

# Add compound column:
df['status'] = df.apply(lambda row: "%s, %s" % (row.stream, row.cdx_status), axis=1)


# And CHART it:
import altair as alt

alt.Chart(df).mark_bar(size=6).encode(
    x='dates:T',
    y='count',
    color='status',
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'), 'stream', 'cdx_status', 'count', 'bytes']
).properties(width=600).interactive()
```
