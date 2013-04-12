//
//  DTITCConstants.h
//  TheMissingAPI
//
//  Created by Oliver Drobnik on 12.04.13.
//  Copyright (c) 2013 Drobnik KG. All rights reserved.
//

#import "DTITC.h"

// kinds of reports
typedef enum
{
    ITCReportTypeUnknown = 0,
	ITCReportTypeSales,
	ITCReportTypeNewsstand
} ITCReportType;

// report sub types
typedef enum
{
    ITCReportSubTypeUnknown = 0,
    ITCReportSubTypeSummary,
    ITCReportSubTypeDetailed,
	ITCReportSubTypeOptIn
} ITCReportSubType;

// report range/date types
typedef enum
{
    ITCReportDateTypeUnknown = 0,
	ITCReportDateTypeDaily,
	ITCReportDateTypeWeekly,
	ITCReportDateTypeMonthly,
    ITCReportDateTypeYearly
} ITCReportDateType;
