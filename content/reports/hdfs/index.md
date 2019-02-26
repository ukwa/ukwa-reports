---
title: HDFS Storage Reports
description: Summaries generated from the data stored on HDFS.
---

# Introduction

The following statistics are generated based on the contents of the HDFS file system we use to store our data. We regularly scan the store and classify each item based on where it is stored, it's file type, and so on. Where possible, we also extract date information, e.g. using the date stamp within the filename of our WARC files to estimate the time that WARC data was collected (although strictly speaking we are using the date the file was created). This means the dates are reliable for all but the earliest years of selective web archiving, i.e. before we started putting the dates in the filenames. 

All figures are in bytes unless otherwise stated.

Deeper analysis can be performed using Python notebooks, e.g. [hdfs-reports-full.ipynb](http://intranet.wa.bl.uk/ukwa/jupyter/notebooks/ukwa-manage/notebooks/hdfs-reports-full.ipynb).

# Non-Print Legal Deposit Content

This section only includes archival content, i.e. WARCs (either normal content or 'viral WARCs' containing material that appears to contain computer viruses), crawl logs and any additional archival package material. 

## NPLD Totals

{{< csv-table src="reports/hdfs/npld-total-file-size-by-stream-totals.csv" >}}

## NPLD Total By Year

{{< csv-table src="reports/hdfs/npld-total-file-size-by-stream-per-year.csv" >}}

## NPLD Total By Month

{{< date-bar-chart src="reports/hdfs/npld-total-file-size-by-stream-per-month.csv" >}}

# All Holdings

These section includes all material on the cluster. If the files appear to be associated with a crawl stream, then the collection (e.g. Non-Print Legal Deposit) and stream (e.g. Domain crawl) will be set. If not, the collection and stream will both be 'None'.

## Total bytes of files on HDFS, by collection, stream and type

This report breaks down the total size of files (in bytes) stored on HDFS by the collection, stream, and type of file.

{{< csv-table src="reports/hdfs/total-file-size-by-stream.csv" >}}

## Total numbers of files on HDFS, by collection, stream and type

This report breaks down the number of files stored on HDFS by the collection, stream, and type of file.

{{< csv-table src="reports/hdfs/total-file-count-by-stream.csv" >}}



