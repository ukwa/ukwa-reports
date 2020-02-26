---
title: UK Web Archive Access Statistics
description: Summaries generated from the various UKWA Access Logs.
---

## Introduction

These figures are drawn from (and divided according to) the logs of the six [Legal Deposit Libraries](https://www.nls.uk/guides/publishers/legal-deposit-libraries). 
We derive them by looking for certain string patterns to identify the lines that can mean something for our analytical purposes.
Deeper analysis can be performed using Python notebooks on the [British Library's Jupyter Hub](https://jupyter.wa.bl.uk/)
For further information or to generate more data or for help with analysis, please contact us using the email link above.

### Key:

* [Distinct Searches] Number of searches performed using unique wording.
* Page Views – The number of actual archive website pages that were viewed by users.
* [Recognised Page Views] - A more reliable version of the above.
* Excluded Page Views - A figure helping us differentiate the Recognised Page Views from the total.
* [Searches] Number of searches performed overall.
* [Users] - Number of Wayback sessions.
* User agents - the software at the user-end that is browsing the archive.


### Notes:

If the second value is httpd then this count comes from the Apache server; if it is Wayback then it comes from OpenWayback (as our LDL services are still running OpenWayback not pywb).
Square brackets [ ] indicate the most useful and reliable statistics.


## Monthly Tables

{{< csv-dir-list dir="content/reports/ukwa-access-stats/" >}}


