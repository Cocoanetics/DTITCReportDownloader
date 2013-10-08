//
//  DTITCReportDownloader.m
//  TheMissingAPI
//
//  Created by Oliver Drobnik on 06.02.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import "DTITC.h"

// private functions
@interface DTITCReportDownloader ()

- (NSString *)_dateStringForReportDate:(NSDate *)date reportDateType:(ITCReportDateType)reportDateType;
- (NSString *)_stringByURLEncodingString:(NSString *)string;
- (NSError *)_genericErrorWithUnderlyingError:(NSError *)error;

@end

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


#pragma mark Downloading

- (BOOL)downloadReportWithDate:(NSDate *)date
                    reportType:(ITCReportType)reportType
                reportDateType:(ITCReportDateType)reportDateType
                 reportSubType:(ITCReportSubType)reportSubType
             completionHandler:(DTITCReportDownloaderCompletionHandler)completionHandler
                  errorHandler:(DTITCReportDownloaderErrorHandler)errorHandler
{
	NSMutableString *body = [NSMutableString string];
	
	// add username
	[body appendFormat:@"USERNAME=%@", [self _stringByURLEncodingString:_user]];
	
	// add password
	[body appendFormat:@"&PASSWORD=%@", [self _stringByURLEncodingString:_password]];
	
	// add vendorID
	[body appendFormat:@"&VNDNUMBER=%@", _vendorIdentifier];
	
	// add report type
    [body appendFormat:@"&TYPEOFREPORT=%@", NSStringFromITCReportType(reportType)];
    
	// add report date type
    [body appendFormat:@"&DATETYPE=%@", NSStringFromITCReportDateType(reportDateType)];
    
    // add report sub type
    [body appendFormat:@"&REPORTTYPE=%@", NSStringFromITCReportSubType(reportSubType)];
    
	// date date
	[body appendFormat:@"&REPORTDATE=%@", [self _dateStringForReportDate:date reportDateType:reportDateType]];
	
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
		if (errorHandler)
		{
			NSError *error = [self _genericErrorWithUnderlyingError:downloadError];
			errorHandler(error);
		}
		
		return NO;
	}
	
	NSDictionary *headers = [response allHeaderFields];
	NSString *errorMsg = [headers objectForKey:@"ERRORMSG"];
	
	if (errorMsg)
	{
		if (errorHandler)
		{
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:1 userInfo:userInfo];
			errorHandler(error);
		}
		return NO;
	}
	
	NSString *fileName = [headers objectForKey:@"filename"];
	
	if (!fileName)
	{
		if (errorHandler)
		{
			NSError *error = [self _genericErrorWithUnderlyingError:nil];
			errorHandler(error);
		}
		
		return NO;
	}
	
	// we got data, we got a filename, we're done!
	
	if (completionHandler)
	{
		completionHandler(fileName, data);
	}
	
	return YES;
}

#pragma mark Utilities
- (NSString *)_dateStringForReportDate:(NSDate *)date reportDateType:(ITCReportDateType)reportDateType
{
	NSString *dateString = nil;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSStringWithDateFormatForITCReportDateType(reportDateType)];
    
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

- (NSString *)_stringByURLEncodingString:(NSString *)string
{
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8 );
	return (__bridge_transfer NSString *)urlString;
}

- (NSError *)_genericErrorWithUnderlyingError:(NSError *)error
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@"The report you requested is not available at this time.  Please try again in a few minutes." forKey:NSLocalizedDescriptionKey];
	
	if (error)
	{
		[userInfo setObject:error forKey:NSUnderlyingErrorKey];
	}
	
	return [NSError errorWithDomain:NSStringFromClass([self class]) code:1 userInfo:userInfo];
}

- (NSString *)predictedFileNameForDate:(NSDate *)date
                            reportType:(ITCReportType)reportType
                        reportDateType:(ITCReportDateType)reportDateType
                         reportSubType:(ITCReportSubType)reportSubType
                            compressed:(BOOL)compressed
{
	NSMutableString *retString = [NSMutableString string];
	
    NSString *reportTypeString = [NSStringFromITCReportType(reportType) substringToIndex:1];
	[retString appendString:reportTypeString];
	
	[retString appendString:@"_"];

    if (reportType != ITCReportTypeSales)
    {
        NSString *reportSubTypeString = [NSStringFromITCReportSubType(reportSubType) substringToIndex:1];
        [retString appendString:reportSubTypeString];
        [retString appendString:@"_"];
    }
    
    NSString *dateTypeString = NSStringFromITCReportDateType(reportDateType);
    
    NSString *shortType = [dateTypeString substringToIndex:1];
    [retString appendString:shortType];
    
	[retString appendString:@"_"];
    
	[retString appendString:_vendorIdentifier];
	
	[retString appendString:@"_"];
	
	[retString appendString:[self _dateStringForReportDate:date reportDateType:reportDateType]];
	
	[retString appendString:@".txt"];
	
	if (compressed)
	{
		if (reportSubType == ITCReportSubTypeOptIn)
		{
			[retString appendString:@".zip"];
		}
		else
		{
			[retString appendString:@".gz"];
		}
	}
    
	return retString;
}


@end
