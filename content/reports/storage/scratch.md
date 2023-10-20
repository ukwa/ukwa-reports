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

# Scratch space

A place to experiment with other analyses

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-cell]
---
import os
import requests
import pandas as pd
from humanbytes import HumanBytes
from IPython.display import display, HTML, FileLink, FileLinks

pd.set_option('display.max_rows', 100)

# Pick up source locations:
trackdb_jsonl = os.environ.get('TRACKDB_LIST_JSONL','trackdb_list.jsonl')
aws_jsonl = os.environ.get('AWS_S3_LIST_JSONL','aws_s3_list.jsonl')

# Load TrackDB records:
df = pd.read_json(trackdb_jsonl, lines=True)

# Also load AWS records:
aws_df = pd.read_json(aws_jsonl, lines=True)
# Filter out non-content files:
aws_df  = aws_df[aws_df['kind_s'] != 'unknown']
df = pd.concat([df,aws_df], sort=True)

# Set up timestamp:
df['timestamp_dt']= pd.to_datetime(df['timestamp_dt'])
total_records = len(df)

# Force integers:
df['file_size_l'] = df['file_size_l'].fillna(0)
df['file_size_l'] = df['file_size_l'].apply(int)

display(HTML(f"Found a total of {total_records:,} WARC and crawl log files."))
```

```{code-cell} ipython3
:tags: [hide-input]

# Dataframe of all unique paths (drop others for paths appearing in more than one 'fresh' TrackDB record):
dfu = df.drop_duplicates(subset=['file_path_s']).drop(columns=['file_path_s'])

unique_records = len(dfu)

display(HTML(f"Found {unique_records:,} unique files (based on file path). This means there are {(total_records-unique_records):,} files duplicated across storage systems."))
```

The following table shows the most recent WARCs for each data store, along with the associated timestamp. This can be used to check the source data for this report is up to date.

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
---

```

```{code-cell} ipython3

```

## Radial Visualization

This is a work in progress and is not working yet.

```{code-cell} ipython3
#for gn, g in dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A"), 'collection_s', 'stream_s', 'hdfs_service_id_s', 'kind_s']):
dfuu = dfu.filter(['timestamp_dt', 'collection_s', 'stream_s', 'hdfs_service_id_s', 'kind_s', 'file_size_l']).rename(
    columns={
        'file_size_l': 'size_bytes', 
        'kind_s': 'kind', 
        'stream_s': 'stream',
        'count': 'file_count',
        'timestamp_dt': 'year',
        'collection_s': 'collection',
        'hdfs_service_id_s': 'store'
    }
)
dfuu
```

```{code-cell} ipython3
# Build up items for the tree:
#  {
#    "id": 246,
#    "name": "TreeMapLayout",
#    "parent": 231,
#    "size": 9191
#  },


entries = []
entry_id = 0

entries.append({
    'id': entry_id,
    'name': "total",
    'size': dfuu['size_bytes'].sum(),
    'count': dfuu['size_bytes'].count()
})
parent_id = entry_id
entry_id += 1

for ts, ts_g in dfuu.groupby(pd.Grouper(key='year', freq="A")):
    print(ts.year)
    for col, col_g in ts_g.groupby('collection'):
        print(ts.year, col, col_g['size_bytes'].count(), col_g['size_bytes'].sum())
        for stream, stream_g in col_g.groupby('stream'):
            print(ts.year, col, stream)
            for kind, kind_g in stream_g.groupby('kind'):
                print(ts.year, col, stream, kind)
                for store, store_g in kind_g.groupby('store'):
                    print(ts.year, col, stream, kind, store, store_g['size_bytes'].count(), store_g['size_bytes'].sum())
```

```{code-cell} ipython3
from altair.vega import vega

vega({
  "$schema": "https://vega.github.io/schema/vega/v5.json",
  "description": "An example of a space-fulling radial layout for hierarchical data.",
  "width": 600,
  "height": 600,
  "padding": 5,
  "autosize": "none",

  "data": [
    {
      "name": "tree",
      "url": "https://vega.github.io/vega/data/flare.json",
      "transform": [
        {
          "type": "stratify",
          "key": "id",
          "parentKey": "parent"
        },
        {
          "type": "partition",
          "field": "size",
          "sort": {"field": "value"},
          "size": [{"signal": "2 * PI"}, {"signal": "width / 2"}],
          "as": ["a0", "r0", "a1", "r1", "depth", "children"]
        }
      ]
    }
  ],

  "scales": [
    {
      "name": "color",
      "type": "ordinal",
      "domain": {"data": "tree", "field": "depth"},
      "range": {"scheme": "tableau10"}
    }
  ],

  "marks": [
    {
      "type": "arc",
      "from": {"data": "tree"},
      "encode": {
        "enter": {
          "x": {"signal": "width / 2"},
          "y": {"signal": "height / 2"},
          "fill": {"scale": "color", "field": "depth"},
          "tooltip": {"signal": "datum.name + (datum.size ? ', ' + datum.size + ' bytes' : '')"}
        },
        "update": {
          "startAngle": {"field": "a0"},
          "endAngle": {"field": "a1"},
          "innerRadius": {"field": "r0"},
          "outerRadius": {"field": "r1"},
          "stroke": {"value": "white"},
          "strokeWidth": {"value": 0.75},
          "zindex": {"value": 0}
        },
        "hover": {
          "stroke": {"value": "red"},
          "strokeWidth": {"value": 1.5},
          "zindex": {"value": 1}
        }
      }
    }
  ]
})
```

```{code-cell} ipython3

```

```{code-cell} ipython3

```

```{code-cell} ipython3

```
