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
			printf("Please enter all the required parameters.  For help, please download the latest User Guide from the Sales and Trends module in iTunes Connect.\n");
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
		
		// set a success handler
		downloader.successCallback = ^(NSString *fileName) {
			printf("%s\nFile Downloaded Successfully\n", [fileName UTF8String]);
		};
		
		// download this report
		NSError *error = nil;
		if (![downloader downloadReportWithDate:reportDate reportType:reportType reportSubType:reportSubType error:&error])
		{
			printf("%s\n", [[error localizedDescription] UTF8String]);
			return 1;
		}
		
	}
    return 0;
}

