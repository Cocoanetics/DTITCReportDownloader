//
//  DTITCFunctions.h
//  TheMissingAPI
//
//  Created by Oliver Drobnik on 12.04.13.
//  Copyright (c) 2013 Drobnik KG. All rights reserved.
//

#import "DTITC.h"

/**
 @name Report Type Conversion
 */

/**
 Converts the report type from enum to `NSString`
 */
NSString *NSStringFromITCReportType(ITCReportType reportType);

/**
 Converts a string representation of a report type to the enum. Supports both the long and short form.
 */
ITCReportType reportTypeFromString(NSString *reportTypeString);


/**
 @name Report Sub Type Conversion
 */

/**
 Converts the report sub type from enum to `NSString`
 */
NSString *NSStringFromITCReportSubType(ITCReportSubType reportSubType);

/**
 Converts a string representation of a report sub type to the enum. Supports both the long and short form.
 */
ITCReportSubType reportSubTypeFromString(NSString *reportSubTypeString);

/**
 @name Report Date Type Conversion
 */

/**
 Converts the report date type from enum to `NSString`
 */
NSString *NSStringFromITCReportDateType(ITCReportDateType reportDateType);

/**
 Converts a string representation of a report date type to the enum. Supports both the long and short form.
 */
ITCReportDateType reportDateTypeFromString(NSString *reportDateTypeString);


/**
 @name Date Formatting
 */

/**
 Retrieves the report date format for a given date type
*/
NSString *NSStringWithDateFormatForITCReportDateType(ITCReportDateType reportDateType);