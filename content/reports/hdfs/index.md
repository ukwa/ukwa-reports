---
title: HDFS Storage Reports
description: Summaries generated from the data stored on HDFS.
---

All figures are in bytes unless otherwise stated.

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

This report breaks down the files stored on HDFS by the collection, stream, and type of file.

{{< csv-table src="reports/hdfs/total-file-size-by-stream.csv" >}}



