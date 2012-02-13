//
//  DTITCReportDownloader.h
//  TheMissingAPI
//
//  Created by Oliver Drobnik on 06.02.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

typedef enum 
{
	ITCReportTypeDaily = 0,
	ITCReportTypeWeekly
} ITCReportType;

typedef enum
{
	ITCReportSubTypeSummary = 0,
	ITCReportSubTypeOptIn
} ITCReportSubType;

typedef void (^DTITCReportDownloaderCompletionHandler)(NSString *fileName, NSData *data);
typedef void (^DTITCReportDownloaderErrorHandler)(NSError *error);

@interface DTITCReportDownloader : NSObject

- (id)initWithUser:(NSString *)user password:(NSString *)password vendorIdentifier:(NSString *)vendorIdentifier;

- (BOOL)downloadReportWithDate:(NSDate *)date reportType:(ITCReportType)reportType reportSubType:(ITCReportSubType)reportSubType completionHandler:(DTITCReportDownloaderCompletionHandler)completionHandler errorHandler:(DTITCReportDownloaderErrorHandler)errorHandler;

- (NSString *)predictedFileNameForDate:(NSDate *)date reportType:(ITCReportType)reportType reportSubType:(ITCReportSubType)reportSubType compressed:(BOOL)compressed;

@end
