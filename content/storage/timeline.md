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

# HDFS Timeline

Breaking down what's stored on HDFS onto a timeline, i.e. totals do not include data held only on AWS Glacier.

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
            'start' : "NOW/YEAR-20YEAR",
            'end' : "NOW/YEAR+1YEAR", 
            'gap' : "+1MONTH", 
            # For each day, we facet based on the CDX Index field, and make sure items with no value get recorded:
            'facet': { 
                'collection': { 
                    'type': 'terms', 
                    "field": "collection_s", 
                    'missing': True,
                    'facet': { 
                        'stream': { 
                            'type': 'terms', 
                            "field": "stream_s", 
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
  'q': '(kind_s:"warcs" OR kind_s:"logs")',
  'rows': 0
}

r = requests.post("http://solr8.api.wa.bl.uk/solr/tracking/select", params=params, data=json.dumps(json_facet), headers=headers)

if r.status_code != 200:
    print(r.text)

df = pd.DataFrame(flatten_solr_buckets(r.json()['facets']))
# Filter empty rows:
df=df[df['count'] != 0]

# Add compound column:
df['status'] = df.apply(lambda row: "%s, %s" % (row.collection, row.stream), axis=1)
df['terabytes'] = df.apply(lambda row: row.bytes / (1000*1000*1000*1000), axis=1)

# CHART
import altair as alt

alt.Chart(df).mark_bar().encode(
    x=alt.X('dates:T', axis = alt.Axis(title = 'Date', format = ("%b %Y"))),
    y=alt.Y('terabytes', axis=alt.Axis(title='Data volume (TB)')),
    color='status:N',
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'),'status:N', 'count', 'terabytes']
).properties(width=600)
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

And the same data as a percentage per time period.

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
alt.Chart(df).mark_bar().encode(
    x=alt.X('dates:T', axis = alt.Axis(title='Date', format=("%b %Y"))),
    y=alt.Y('count', stack="normalize", axis=alt.Axis(title='Percentage of files', format='%')),
    color='status:N',
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'),'status:N', 'count', 'bytes']
).properties(width=600)
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

And as a cumulative graph.

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
import altair as alt

alt.Chart(df).transform_window(
    cumulative_terabytes="sum(terabytes)",
).mark_line().encode(
    x=alt.X('dates:T', axis=alt.Axis(title='Date', format=("%b %Y"))),
    y=alt.Y('cumulative_terabytes:Q', axis=alt.Axis(title='Cumulative total data volume (TB)')),
    tooltip=[alt.Tooltip('dates:T', format='%A, %e %B %Y'), 'cumulative_terabytes:Q']
).properties(width=600)
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

And as cumulative totals (calculated directly rather than using the graph library):

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
df2 = df.groupby(['status'])['terabytes'].sum().groupby(level=0).cumsum().reset_index()
df2
```
