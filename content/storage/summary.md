---
jupytext:
  formats: md:myst
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

# Storage Summary Report

## Introduction
Every day, all active data stores are scanned and their inventories taken. This report uses that data to summarise our current holdings in terms of volumes of data and numbers of files.  We classify files in various ways, and provide summary statistics based on those groupings.  They include:

| Classification | Description |
| -------------- | ----------- |
**Date**       | File creation date by e.g. year, or financial year, or month, etc.   |
**Collection** | The legal framework we collect under. One of `selective`, `npld` or `bypm` (by permission)  
| **Stream**     | The capture process, e.g. `selective` (WCT), `frequent`, `domain`, `webrecorder`, `warcit` |
| **Kind**       | The kind of file, e.g. `warcs`, `viral` (meaning WARCs of nullified viral records), `crawl-logs` etc. |
| **Store**      | The storage system the files reside on, e.g. `h020` (old Hadoop), `h3` (new Hadoop), `aws_s3` (AWS S3 Glacier) |  |

+++ {"editable": true, "slideshow": {"slide_type": ""}}

## Current Totals

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
import os
import requests
import pandas as pd
from humanbytes import HumanBytes
from IPython.display import display, HTML, FileLink, FileLinks
import pathlib

# Helper function to show a table and offer a downloadable version:
def show_table_and_dl(df, slug):
    # Shift to standard Column Names
    df = df.rename(columns={
        'timestamp_dt': 'year',
        'collection_s': 'collection',
        'stream_s': 'stream',
        'kind_s': 'kind',
        'size': 'size_bytes',
        'count': 'file_count',
        'hdfs_service_id_s': 'store'
    })

    # Add a Total:
    df.loc['Total']= df.sum(numeric_only=True)
    
    # Replace NaNs
    df = df.fillna('')

    # Clean up size formatting:
    df['size'] = df['size_bytes'].apply(lambda x: HumanBytes.format(x, True))
    df['size_bytes'] = df['size_bytes'].apply(int)
    df['file_count'] = df['file_count'].apply(int)
    
    # Also make the data available for download:
    csv_file = f'{slug}.csv'
    df.to_csv(csv_file, index=False)
    dl = FileLink(csv_file, result_html_prefix='Download the data from this table here: ')
    display(df,dl)

# Establish the current folder:
dir_path = pathlib.Path().absolute()

# Display more rows by default:
pd.set_option('display.max_rows', 100)

# Pick up source locations:
trackdb_jsonl = os.environ.get('TRACKDB_LIST_JSONL', dir_path.joinpath('trackdb_list.jsonl'))
aws_jsonl = os.environ.get('AWS_S3_LIST_JSONL', dir_path.joinpath('aws_s3_list.jsonl'))

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
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
# Dataframe of all unique paths (drop others for paths appearing in more than one 'fresh' TrackDB record):
dfu = df.drop_duplicates(subset=['file_path_s']).drop(columns=['file_path_s'])

unique_records = len(dfu)

display(HTML(f"Found {unique_records:,} unique files (based on file path). This means there are {(total_records-unique_records):,} files duplicated across storage systems."))
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

## Most Recent Files
The following table shows the most recent WARCs for each data store, along with the associated timestamp. This can be used to check the source data for this report is up to date, as the date for the `h3` store should be within the last day or two.

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
pd.set_option('display.max_colwidth', 1024)
# Now we look for the most recent WARC files:
dflw = df.filter(items=['hdfs_service_id_s', 'file_path_s', 'kind_s', 'timestamp_dt'], axis=1)
dflw = dflw.loc[dflw['kind_s'] == 'warcs'].sort_values(['timestamp_dt'],ascending=False).groupby('hdfs_service_id_s').first()
dflw = dflw.reset_index().rename(columns={
    'hdfs_service_id_s': 'store',
})
dflw
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

## Totals by Collection & Stream

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
tots = dfu.groupby(['collection_s','stream_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = tots.reset_index()

# Show table and downloader:
show_table_and_dl(tots, 'totals_by_collection_and_stream')
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

## Statistics by Year

### Overall totals by year

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
#tots = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A"), 'collection_s', 'stream_s', 'hdfs_service_id_s', 'kind_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A")]).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = tots.reset_index()

# Clip year:
tots['timestamp_dt'] = tots['timestamp_dt'].dt.year.apply(lambda x: str(x))

# Show table and downloader:
show_table_and_dl(tots, 'totals_by_year')
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

### Totals by Year & Collection

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
#tots = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A"), 'collection_s', 'stream_s', 'hdfs_service_id_s', 'kind_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A"), 'collection_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = tots.reset_index()

# Clip year:
tots['timestamp_dt'] = tots['timestamp_dt'].dt.year.apply(lambda x: str(x))

# Show table and downloader:
show_table_and_dl(tots, 'totals_by_year_collection')
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

### Totals by Year & Stream

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
tots = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A"), 'stream_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = tots.reset_index()

# Clip year:
tots['timestamp_dt'] = tots['timestamp_dt'].dt.year.apply(lambda x: str(x))

# Show table and downloader:
show_table_and_dl(tots, 'totals_by_year_stream')
```

+++ {"editable": true, "slideshow": {"slide_type": ""}}

### Totals by Year, Collection, Stream, Store & Kind

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
tots = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A"), 'collection_s', 'stream_s', 'hdfs_service_id_s', 'kind_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))
tots = tots.reset_index()

# Clip year:
tots['timestamp_dt'] = tots['timestamp_dt'].dt.year.apply(lambda x: str(x))

# Show table and downloader:
show_table_and_dl(tots, 'totals_by_year_collection_stream_store_kind')
```

## Statistics by Financial Year

The same data, but aggregating by financial year.

### Totals by Financial Year

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
by_fy = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A-MAR")]).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))

# Removed heirarchical index so we can plot:
by_fy = by_fy.reset_index()

# Transform how FY is presented:
by_fy['timestamp_dt'] = by_fy['timestamp_dt'].dt.year.apply(lambda x: str(x-1) + "-" + str(x))

# Show table and downloader:
show_table_and_dl(by_fy, 'totals_by_fy')
```

### Totals by Financial Year, Collection, Stream, Store & Kind

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
by_fy = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A-MAR"), 'collection_s', 'stream_s', 'hdfs_service_id_s', 'kind_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))

# Removed heirarchical index so we can plot:
by_fy = by_fy.reset_index()

# Transform how FY is presented:
by_fy['timestamp_dt'] = by_fy['timestamp_dt'].dt.year.apply(lambda x: str(x-1) + "-" + str(x))

# Show table and downloader:
show_table_and_dl(by_fy, 'totals_by_fy_collection_stream_store_kind')
```

### Graphs of Totals by Stream & Kind, over Time

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
by_fy_s = dfu.groupby([pd.Grouper(key='timestamp_dt', freq="A-MAR"), 'stream_s', 'kind_s']).agg(count=('file_size_l', 'count'), size=('file_size_l', 'sum'))

# Removed heirarchical index so we can plot:
by_fy_s = by_fy_s.reset_index()

# Transform how FY is presented:
by_fy_s['fy'] = by_fy_s['timestamp_dt'].dt.year.apply(lambda x: str(x-1) + "-" + str(x))

# Refactor/renaming:
by_fy_s = by_fy_s.filter(['fy', 'stream_s', 'kind_s', 'count', 'size'])

# Present sizes in a readable way
by_fy_s['readable_size'] = by_fy_s['size'].apply(lambda x: HumanBytes.format(x, True))
```

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
tags: [remove-input]
---
import altair as alt

selection = alt.selection_point(fields=['stream_s'])
color = alt.condition(
    selection,
    alt.Color('stream_s:N').legend(None),
    alt.value('lightgray')
)

scatter = alt.Chart(by_fy_s).mark_bar().encode(
    x=alt.X('fy', axis = alt.Axis(title = 'Financial year')),
    y=alt.Y('size', axis = alt.Axis(title = 'Total bytes', format='s')),
    color=color,
    row=alt.Row('kind_s', title='Kind'),
    tooltip=[
        alt.Tooltip('fy', title='Financial year'), 
        alt.Tooltip('stream_s', title='Content stream'), 
        alt.Tooltip('count', title='Number of files'), 
        alt.Tooltip('readable_size', title='Total bytes')
    ]
).properties(
    width=600,height=200
).resolve_scale(y='independent')

legend = alt.Chart(by_fy_s).mark_point().encode(
    alt.Y('stream_s').axis(orient='right'),
    color=color
).add_params(
    selection
)

scatter | legend
```

```{code-cell} ipython3
---
editable: true
slideshow:
  slide_type: ''
---

```
