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
			printf("report_type     This is the report type you want to download. Available: Sales, Opt-In, Newsstand\n");
			printf("date_type       Yearly will provide you the Yearly version of the report\n");
			printf("                Monthly will provide you the Monthly version of the report\n");
			printf("                Weekly will provide you the Weekly version of the report\n");
			printf("                Daily will provide you the Daily version of the report\n");
			printf("report_subtype  Summary, Detailed or Opt-In, this is the parameter for the Sales Reports\n");
			printf("date_yyyymmdd   The date parameter is optional. Omit it to use yesterday's date.\n");
			printf("                If you specify ALL for the date then the tool will try to download all reports of this type.\n\n");
			
			return 1;
		}
		
		__block NSDate *reportDate = nil;
		BOOL downloadAll = NO;
		
		NSString *user = [NSString stringWithUTF8String:argv[1]];
		NSString *password = [NSString stringWithUTF8String:argv[2]];
		NSString *vendor = [NSString stringWithUTF8String:argv[3]];
		
		NSString *reportTypeString = [NSString stringWithUTF8String:argv[4]];
		ITCReportType reportType = reportTypeFromString(reportTypeString);
		
		if (!reportType)
		{
			printf("Invalid report type '%s'. Only report type 'Sales', 'Newsstand' or 'Opt-In' supported.\n", [reportTypeString UTF8String]);
			return 1;
		}
		
		NSString *dateTypeString = [NSString stringWithUTF8String:argv[5]];
		ITCReportDateType reportDateType = reportDateTypeFromString(dateTypeString);
		
		if (!reportDateType)
		{
			printf("Invalid day type '%s'. Only day types 'Daily','Weekly','Monthly' and 'Yearly' supported.\n", [dateTypeString UTF8String]);
			return 1;
		}
		
		NSString *reportSubTypeString = [NSString stringWithUTF8String:argv[6]];
		ITCReportSubType reportSubType = reportSubTypeFromString(reportSubTypeString);
		
		if (!reportSubType)
		{
			printf("Invalid report sub type '%s'. Only sub types 'Summary' and 'Detailed' supported.\n", [reportSubTypeString UTF8String]);
			return 1;
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		NSString *dateFormat = NSStringWithDateFormatForITCReportDateType(reportDateType);
		
		[formatter setDateFormat:dateFormat];
		
		// check for optional date parameter
		if (argc == 8)
		{
			NSString *dateParam = [NSString stringWithUTF8String:argv[7]];
			
			if ([[dateParam lowercaseString] isEqualToString:@"all"])
			{
				downloadAll = YES;
			}
			else
			{
				// make it a date
				reportDate = [formatter dateFromString:dateParam];
				
				if (!reportDate)
				{
					printf("Invalid date parameter '%s'. Specify date as %s or ALL.\n", [dateParam UTF8String], [dateFormat UTF8String]);
					return 1;
				}
			}
		}
		
		if (!reportDate)
		{
			// no date passed, get yesterday
			NSDate *today = [NSDate date];
			
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setDay:-1];
			
			reportDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:today options:0];
		}
		
		// for weekly reports go back to previous Sunday
		if (reportDateType == ITCReportDateTypeWeekly)
		{
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			
			NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:reportDate];
			
			if (comps.weekday!=1) // not a Sunday
			{
				comps.day = -(comps.weekday-1);
				comps.weekday = 0;
				
				reportDate = [gregorian dateByAddingComponents:comps toDate:reportDate options:0];
			}
		}
		
		// create a downloader
		DTITCReportDownloader *downloader = [[DTITCReportDownloader alloc] initWithUser:user password:password vendorIdentifier:vendor];
		
		__block NSUInteger downloadedFiles = 0;
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *cwd = [fileManager currentDirectoryPath];
		
		do
		{
			NSString *predictedName = [downloader predictedFileNameForDate:reportDate
																				 reportType:reportType
																			reportDateType:reportDateType
																			 reportSubType:reportSubType
																				 compressed:YES];
			
			NSString *predictedOutputPath = [cwd stringByAppendingPathComponent:predictedName];
			
			if ([fileManager fileExistsAtPath:predictedOutputPath])
			{
				printf("Skipped %s\n", [predictedName UTF8String]);
				downloadedFiles++;
				
				if (!downloadAll)
				{
					break;
				}
			}
			else if ([downloader downloadReportWithDate:reportDate
														reportType:reportType
												  reportDateType:reportDateType
													reportSubType:reportSubType
											  completionHandler:^(NSString *fileName, NSData *data) {
												  NSString *baseName = [fileName stringByReplacingOccurrencesOfString:@".txt.gz" withString:@""];
												  
												  // update actual report date
												  NSString *dateFormat = NSStringWithDateFormatForITCReportDateType(reportDateType);
												  
												  NSString *dateStringInName = [baseName substringWithRange:NSMakeRange([baseName length]-[dateFormat length], [dateFormat length])];
												  formatter.dateFormat = dateFormat;
												  NSDate *parsedDate = [formatter dateFromString:dateStringInName];
												  
												  if ([parsedDate compare:reportDate] == NSOrderedDescending)
												  {
													  // cancel loop, this file does not fit with what we requested
													  reportDate = nil;
													  
													  return;
												  }
												  else
												  {
													  reportDate = parsedDate;
												  }
												  
												  // get current working directory
												  NSString *outputPath = [cwd stringByAppendingPathComponent:fileName];
												  
												  // skip this file if output already exists
												  if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
												  {
													  printf("Skipped %s\n", [fileName UTF8String]);
													  downloadedFiles++;
													  
													  return;
												  }
												  
												  // write data to file
												  NSError *writeError = nil;
												  if ([data writeToFile:outputPath options:NSDataWritingAtomic error:&writeError])
												  {
													  printf("%s\n", [fileName UTF8String]);
													  downloadedFiles++;
												  }
												  else
												  {
													  printf("%s\n", [[writeError localizedDescription] UTF8String]);
												  }
											  }
						 
													 errorHandler:^(NSError *error) {
														 if (!downloadAll)
														 {
															 // don't output single file errors for ALL mode
															 printf("%s\n", [[error localizedDescription] UTF8String]);
														 }
													 }])
			{
				// download succeeded for this date
				if (!downloadAll)
				{
					break;
				}
			}
			else
			{
				// download failed for this date
				if (!downloadAll)
				{
					// abort for single file
					break;
				}
				else
				{
					if (downloadedFiles>0)
					{
						// if we are downloading all the first failure means we end
						break;
					}
				}
			}
			
			if (downloadAll)
			{
				// move to one day/week/month/year earlier
				NSDateComponents *comps = [[NSDateComponents alloc] init];
				
				switch (reportDateType)
				{
					case ITCReportDateTypeDaily:
					{
						[comps setDay:-1];
						break;
					}
						
					case ITCReportDateTypeWeekly:
					{
						[comps setDay:-7];
						break;
					}
						
					case ITCReportDateTypeMonthly:
					{
						[comps setMonth:-1];
						break;
					}
						
					case ITCReportDateTypeYearly:
					{
						[comps setYear:-1];
						break;
					}
						
					default:
					{
						break;
					}
				}
				
				if (!reportDate)
				{
					break;
				}
				
				reportDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:reportDate options:0];
 			}
			
		} while (1);
		
		
		if (downloadedFiles)
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
