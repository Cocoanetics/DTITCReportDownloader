ITC Report Downloader
=====================

We are [lobbying since 2009](http://www.cocoanetics.com/2009/04/petition-itunes-sales-report-api/) to get Apple to publish a proper API for downloading all kinds of reports. 

The first reaction we got was [prohibition of ITC scraping](http://www.cocoanetics.com/2009/03/apple-rejects-incredibly-useful-itunes-report-app/). The second reaction was that Apple created the Mobile ITC app which unfortunately lacks any kind of possibility to get the reports out or get monetary amounts. The third reaction was a half-harted publishing of a Java class that is able to download daily and weekly sales reports. 

This project is a complete rewrite of the Autoingest Java class in proper Objective-C. This way we iOS and Mac developers can at least download these two kinds of reports without having to have a JVM installed.

Please support our cause by duping Radar [rdar://6807195](http://openradar.appspot.com/radar?id=51416) which is still lacking any kind of response. I was told back in 2009 that "if enough developers wanted it" Apple would finally give us the API we are wishing for.

Follow [@cocoanetics](http://twitter.com/cocoanetics) on Twitter.

License
------- 
 
It is open source and covered by a standard BSD license. That means you have to mention *Cocoanetics* as the original author of this code. You can purchase a Non-Attribution-License from us.

Usage
-----

The Project consists of a static library with the DTITCReportDownloader class and a Demo project creating an Autoingest command line tool which behaves exactly like its Java cousin.


If you find an issue then you are welcome to fix it and contribute your fix via a GitHub pull request.
