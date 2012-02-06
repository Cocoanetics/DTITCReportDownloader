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


@interface DTITCReportDownloader : NSObject
{
	void (^_successCallback)(NSString *fileName);
}


- (id)initWithUser:(NSString *)user password:(NSString *)password vendorIdentifier:(NSString *)vendorIdentifier;

- (BOOL)downloadReportWithDate:(NSDate *)date reportType:(ITCReportType)reportType reportSubType:(ITCReportSubType)reportSubType error:(NSError **)error;

@property (nonatomic, copy) void (^successCallback)(NSString *fileName);

@end
