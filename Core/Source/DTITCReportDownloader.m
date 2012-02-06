//
//  DTITCReportDownloader.m
//  TheMissingAPI
//
//  Created by Oliver Drobnik on 06.02.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import "DTITCReportDownloader.h"

@implementation DTITCReportDownloader
{
	NSString *_user;
	NSString *_password;
	NSString *_vendorIdentifier;
}

- (id)initWithUser:(NSString *)user password:(NSString *)password vendorIdentifier:(NSString *)vendorIdentifier
{
	self = [super init];
	
	if (self)
	{
		_user = [user copy];
		_password = [password copy];
		_vendorIdentifier = [vendorIdentifier copy];
	}

	return self;
}

- (NSString *)dateStringForReportDate:(NSDate *)date
{
	NSString *dateString = nil;

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd"];

	NSDate *today = [NSDate date];

	if (date)
	{
		dateString = [formatter stringFromDate:date];
	}
	else
	{
		// no date passed, get yesterday
		NSCalendar *calendar = [NSCalendar currentCalendar];
		
		NSDateComponents *comps = [[NSDateComponents alloc] init];
		[comps setDay:-1];
		
		NSDate *yesterday = [calendar dateByAddingComponents:comps toDate:today options:0];
		
		dateString = [formatter stringFromDate:yesterday];
	}
	
	return dateString;
}

- (NSString *)stringByURLEncodingString:(NSString *)string
{
		CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
																							 NULL,
																							 (__bridge CFStringRef)string,
																							 NULL,
																							 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																							 kCFStringEncodingUTF8 );
		return (__bridge_transfer NSString *)urlString;
}

- (NSError *)genericErrorWithUnderlyingError:(NSError *)error
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@"The report you requested is not available at this time.  Please try again in a few minutes." forKey:NSLocalizedDescriptionKey];
	
	if (error)
	{
		[userInfo setObject:error forKey:NSUnderlyingErrorKey]; 
	}
	
	return [NSError errorWithDomain:NSStringFromClass([self class]) code:1 userInfo:userInfo];
}


- (BOOL)downloadReportWithDate:(NSDate *)date reportType:(ITCReportType)reportType reportSubType:(ITCReportSubType)reportSubType error:(NSError **)error
{
	NSMutableString *body = [NSMutableString string];
	
	// add username
	[body appendFormat:@"USERNAME=%@", [self stringByURLEncodingString:_user]];
	
	// add password
	[body appendFormat:@"&PASSWORD=%@", [self stringByURLEncodingString:_password]];
	
	// add vendorID
	[body appendFormat:@"&VNDNUMBER=%@", _vendorIdentifier];
	
	// add report type, only Sales valid at this moment
	[body appendString:@"&TYPEOFREPORT=Sales"];
	 
	// add report type
	[body appendFormat:@"&DATETYPE=%@", (reportType==ITCReportTypeDaily)?@"Daily":@"Weekly"];

	// add report sub type
	[body appendFormat:@"&REPORTTYPE=%@", (reportType==ITCReportSubTypeSummary)?@"Summary":@"Opt-In"];
	
	// date date
	[body appendFormat:@"&REPORTDATE=%@", [self dateStringForReportDate:date]];
	
	// construct the URL request
	NSURL *apiURL = [NSURL URLWithString:@"https://reportingitc.apple.com/autoingestion.tft?"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	// set the body
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSHTTPURLResponse *response = nil;
	NSError *downloadError = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response
																						 error:&downloadError];
	
	if (!data)
	{
		if (error)
		{
			*error = [self genericErrorWithUnderlyingError:downloadError];
		}
		return NO;
	}
	
	NSDictionary *headers = [response allHeaderFields];
	NSString *errorMsg = [headers objectForKey:@"ERRORMSG"];
	
	if (errorMsg)
	{
		if (error)
		{
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:NSStringFromClass([self class]) code:1 userInfo:userInfo];
		}
		return NO;
	}
	
	NSString *fileName = [headers objectForKey:@"filename"];
	
	if (!fileName)
	{
		if (error)
		{
			*error = [self genericErrorWithUnderlyingError:nil];
		}
		
		return NO;
	}
	
	NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];
	NSString *outputPath = [cwd stringByAppendingPathComponent:fileName];
	
	// write data to file
	NSError *writeError = nil;
	if ([data writeToFile:outputPath options:NSDataWritingAtomic error:&writeError])
	{
		if (_successCallback)
		{
			_successCallback(fileName);
		}
	}
	else
	{
		// could not write
		if (error)
		{
			*error = writeError;
			return NO;
		}
	}
	
	return YES;
}

#pragma mark Properties

@synthesize successCallback = _successCallback;


@end
