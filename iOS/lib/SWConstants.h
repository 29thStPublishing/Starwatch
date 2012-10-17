//
//  SWConstants.h
//  Starwatch-Basic
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWConstants : NSObject

+(BOOL)actions_to_stderr;
+(BOOL)send_stats;
+(NSString*)database_name;
+(NSDictionary*)mongo_settings;
+(NSString*)db_version;
+(BOOL)collect_stats;

@end

