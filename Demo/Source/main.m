//
//  main.m
//  Autoingest
//
//  Created by Oliver Drobnik on 06.02.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import "DTITCReportDownloader.h"

int main (int argc, const char * argv[])
{
	
	@autoreleasepool 
	{
		// check for invalid number of parameters
		if (argc<7 || argc>8)
		{
			printf("Usage: Autoingest <username> <password> <vendorid> <report_type> <date_type> <report_subtype> [<date_yyyymmdd>]\n\n");
			printf("username        The user name you use to log into iTunes Connect\n");
			printf("password        The password you use to log into iTunes Connect\n");
			printf("vendorid        Vendor ID (8####### )for the entity which you want to download the report\n");
			printf("report_type     This is the report type you want to download. Cur- rently only Sales Reports are available\n");
			printf("date_type       Weekly will provide you the Weekly version of the report\n");
			printf("                Daily will provide you the Daily version of the report\n");
			printf("report_subtype  Summary or Opt-In, this is the parameter for the Sales Reports\n");
			printf("date_yyyymmdd   The date parameter is optional. Omit it to use yesterday's date\n\n");
			
			return 1;
		}
		
		NSDate *reportDate = nil;
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyyMMdd"];
		
		// check for optional date parameter
		if (argc == 8)
		{
			// make it a date
			reportDate = [formatter dateFromString:[NSString stringWithUTF8String:argv[7]]];
		}
		else
		{
			// no date passed, get yesterday
			NSCalendar *calendar = [NSCalendar currentCalendar];
			
			NSDate *today = [NSDate date];
			
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setDay:-1];
			
			reportDate = [calendar dateByAddingComponents:comps toDate:today options:0];
		}
		
		if (!reportDate)
		{
			printf("Invalid Date passed");
			return 1;
		}
		
		NSString *user = [NSString stringWithUTF8String:argv[1]];
		NSString *password = [NSString stringWithUTF8String:argv[2]]; 
		NSString *vendor = [NSString stringWithUTF8String:argv[3]]; 
		
		NSString *reportTypeString = [NSString stringWithUTF8String:argv[4]];
		ITCReportType reportType;
		if ([reportTypeString isEqualToString:@"Daily"])
		{
			reportType = ITCReportTypeDaily;
		}
		else if ([reportTypeString isEqualToString:@"Weekly"])
		{
			reportType = ITCReportTypeWeekly;
		}
		
		NSString *reportSubTypeString = [NSString stringWithUTF8String:argv[5]];
		ITCReportSubType reportSubType;
		if ([reportSubTypeString isEqualToString:@"Summary"])
		{
			reportSubType = ITCReportSubTypeSummary;
		}
		else if ([reportTypeString isEqualToString:@"Opt-In"])
		{
			reportSubType = ITCReportSubTypeOptIn;
		}
		
		// create a downloader
		DTITCReportDownloader *downloader = [[DTITCReportDownloader alloc] initWithUser:user password:password vendorIdentifier:vendor];
		
		if ([downloader downloadReportWithDate:reportDate
									reportType:reportType
								 reportSubType:reportSubType
							 completionHandler:^(NSString *fileName, NSData *data) {
								 // get current working directory
								 NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];
								 NSString *outputPath = [cwd stringByAppendingPathComponent:fileName];
								 
								 // write data to file
								 NSError *writeError = nil;
								 if (![data writeToFile:outputPath options:NSDataWritingAtomic error:&writeError])
								 {
									 printf("%s\n", [[writeError localizedDescription] UTF8String]);
								 }
							 }
			 
								  errorHandler:^(NSError *error) {
									  printf("%s\n", [[error localizedDescription] UTF8String]); 
								  }])
		{
			// success
			return 0;
		}
		else
		{
			// failure
			return 1;
		}
	}
}

