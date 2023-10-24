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

# DLS Comparison

Comparing holdings on HDFS with what's in DLS, based on the status information stored in the tracking database.

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
            'start' : "NOW/YEAR-10YEAR",
            'end' : "NOW/YEAR+1YEAR", 
            'gap' : "+1MONTH", 
            # For each day, we facet based on the CDX Index field, and make sure items with no value get recorded:
            'facet': { 
                'stream': { 
                    'type': 'terms', 
                    "field": "stream_s", 
                    'missing': True,
                    'facet': { 
                        'index_status': { 
                            'type': 'terms', 
                            "field": "dls_status_i", 
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
  'q': '(kind_s:"warcs" OR kind_s:"logs") AND collection_s:"npld"',
  'rows': 0
}

r = requests.post("http://trackdb.dapi.wa.bl.uk/solr/tracking/select", params=params, data=json.dumps(json_facet), headers=headers)

if r.status_code != 200:
    print(r.text)

df = pd.DataFrame(flatten_solr_buckets(r.json()['facets']))
# Filter empty rows:
df=df[df['count'] != 0]

# Add compound column:
df['status'] = df.apply(lambda row: "%s, status %s" % (row.stream, row.index_status), axis=1)

# And CHART
import altair as alt

alt.Chart(df).mark_bar().encode(
    x=alt.X('dates:T', axis = alt.Axis(title = 'Date', format = ("%b %Y"))),
    y=alt.Y('bytes'),
    color='status:N',
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'),'status:N', 'count', 'bytes']
).properties(width=600).interactive()
```

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
            'start' : "NOW/YEAR-10YEAR",
            'end' : "NOW/YEAR+1YEAR", 
            'gap' : "+1MONTH", 
            # For each day, we facet based on the CDX Index field, and make sure items with no value get recorded:
            'facet': { 
                'stream': { 
                    'type': 'terms', 
                    "field": "stream_s", 
                    'missing': True,
                    'facet': { 
                        'index_status': { 
                            'type': 'terms', 
                            "field": "dls_status_i", 
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
  'q': '(kind_s:"warcs" OR kind_s:"logs") AND collection_s:"npld"',
  'rows': 0
}

r = requests.post("http://trackdb.dapi.wa.bl.uk/solr/tracking/select", params=params, data=json.dumps(json_facet), headers=headers)

if r.status_code != 200:
    print(r.text)

df = pd.DataFrame(flatten_solr_buckets(r.json()['facets']))
# Filter empty rows:
df=df[df['count'] != 0]

# Add compound column:
df['status'] = df.apply(lambda row: "%s, status %s" % (row.stream, row.index_status), axis=1)

# And CHART
import altair as alt

alt.Chart(df).mark_bar().encode(
    x=alt.X('dates:T', axis = alt.Axis(title = 'Date', format = ("%b %Y"))),
    y=alt.Y('bytes'),
    color='status:N',
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'),'status:N', 'count', 'bytes']
).properties(width=600).interactive()
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

And the same data, shown as percentage of bytes rather than total bytes.

```{code-cell} ipython3
---
editable: true
jupyter:
  source_hidden: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
alt.Chart(df).mark_bar().encode(
    x=alt.X('dates:T', axis = alt.Axis(title = 'Date', format = ("%b %Y"))),
    y=alt.Y('count', stack="normalize", axis=alt.Axis(format='%')),
    color='status:N',
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'),'status:N', 'count', 'bytes']
).properties(width=600).interactive()
```

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
---

```

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
---

```
