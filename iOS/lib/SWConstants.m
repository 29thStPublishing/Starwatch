//
//  SWConstants.m
//  Starwatch-Basic
//
//  Created by nataliepo on 10/13/12.
//  Copyright (c) 2012 Twenty Ninth Street Publishing. All rights reserved.
//

#import "SWConstants.h"

#pragma Stats
@implementation SWConstants


+(BOOL)collect_stats {
    return YES;
}

+(BOOL)actions_to_stderr {
    return YES;
}
+(BOOL)send_stats {
    return NO;
}
+(NSString*)database_name {
    return @"starwatch.sqlite";
}
+(NSDictionary*)mongo_settings {
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                //@"db_collection",
                                                @"log",
                                                
                                                //@"db_host",
                                                @"ds123456.mongolab.com",
                                                
                                                //@"db_name",
                                                @"******",
                                                
                                                //@"db_password",
                                                @"******",
                                                
                                                //@"db_user",
                                                @"******",
                                                
                                                //@"db_port",
                                                @"12345678",
                                                
                                                nil]
                                       forKeys:[NSArray arrayWithObjects:
                                                @"db_collection",
                                                @"db_host",
                                                @"db_name",
                                                @"db_password",
                                                @"db_user",
                                                @"db_port",
                                                nil]
            ];
}

+(NSString*)db_version {
    return @"1.0";
}


@end
