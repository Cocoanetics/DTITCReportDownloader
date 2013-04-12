//
//  DTITCFuncations.m
//  TheMissingAPI
//
//  Created by Oliver Drobnik on 12.04.13.
//  Copyright (c) 2013 Drobnik KG. All rights reserved.
//

#import "DTITC.h"

/**
 Functions to convert between enum and string representations
 */

#pragma mark - Report Type Conversion

NSString *NSStringFromITCReportType(ITCReportType reportType)
{
    switch (reportType)
    {
        case ITCReportTypeSales:
        {
            return @"Sales";
        }
            
        case ITCReportTypeNewsstand:
        {
            return @"Newsstand";
        }
            
        default:
        {
            return nil;
        }
    }
}

ITCReportType reportTypeFromString(NSString *reportTypeString)
{
    if ([reportTypeString isEqualToString:@"Sales"] || [reportTypeString isEqualToString:@"S"])
    {
        return ITCReportTypeSales;
    }
    else if ([reportTypeString isEqualToString:@"Newsstand"] || [reportTypeString isEqualToString:@"N"])
    {
        return ITCReportTypeNewsstand;
    }
    
    return ITCReportTypeUnknown;
}

#pragma mark - Report Sub Type Conversion

NSString *NSStringFromITCReportSubType(ITCReportSubType reportSubType)
{
    switch (reportSubType)
    {
        case ITCReportSubTypeSummary:
        {
            return @"Summary";
        }
            
        case ITCReportSubTypeDetailed:
        {
            return @"Detailed";
        }
            
        case ITCReportSubTypeOptIn:
        {
            return @"Opt-In";
        }
            
        default:
        {
            return nil;
        }
    }
}

ITCReportSubType reportSubTypeFromString(NSString *reportSubTypeString)
{
    if ([reportSubTypeString isEqualToString:@"Summary"] || [reportSubTypeString isEqualToString:@"S"])
    {
        return ITCReportSubTypeSummary;
    }
    else if ([reportSubTypeString isEqualToString:@"Detailed"] || [reportSubTypeString isEqualToString:@"D"])
    {
        return ITCReportSubTypeDetailed;
    }
    else if ([reportSubTypeString isEqualToString:@"Opt-In"] || [reportSubTypeString isEqualToString:@"O"])
    {
        return ITCReportSubTypeOptIn;
    }
    
    return ITCReportSubTypeUnknown;
}

#pragma mark - Report Date Type Conversion

NSString *NSStringFromITCReportDateType(ITCReportDateType reportDateType)
{
    switch (reportDateType)
    {
        case ITCReportDateTypeDaily:
        {
            return @"Daily";
        }
            
        case ITCReportDateTypeWeekly:
        {
            return @"Weekly";
        }
            
        case ITCReportDateTypeMonthly:
        {
            return @"Monthly";
        }
            
        case ITCReportDateTypeYearly:
        {
            return @"Yearly";
        }
            
        default:
        {
            return nil;
        }
    }
}

ITCReportDateType reportDateTypeFromString(NSString *reportDateTypeString)
{
    if ([reportDateTypeString isEqualToString:@"Daily"] || [reportDateTypeString isEqualToString:@"D"])
    {
        return ITCReportDateTypeDaily;
    }
    else if ([reportDateTypeString isEqualToString:@"Weekly"] || [reportDateTypeString isEqualToString:@"W"])
    {
        return ITCReportDateTypeWeekly;
    }
    else if ([reportDateTypeString isEqualToString:@"Monthly"] || [reportDateTypeString isEqualToString:@"M"])
    {
        return ITCReportDateTypeMonthly;
    }
    else if ([reportDateTypeString isEqualToString:@"Yearly"] || [reportDateTypeString isEqualToString:@"Y"])
    {
        return ITCReportDateTypeYearly;
    }
    
    return ITCReportDateTypeUnknown;
}

#pragma mark - Date Formatting

NSString *NSStringWithDateFormatForITCReportDateType(ITCReportDateType reportDateType)
{
    switch (reportDateType)
    {
        case ITCReportDateTypeDaily:
        case ITCReportDateTypeWeekly:
        default:
        {
            return @"yyyyMMdd";
        }
            
        case ITCReportDateTypeMonthly:
        {
           return @"yyyyMM";
        }
            
        case ITCReportDateTypeYearly:
        {
            return @"yyyy";
        }
    }
}
