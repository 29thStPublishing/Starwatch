//
//  SWSender.h
//  StarWatch
//
//  Created by Natalie Podrazik on 1/18/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mongo.h"



@interface SWSender : NSObject {
    
}

+(void)sendData;



+(BOOL)hasInternetConnection;
+(void)sendOldestRecords:(int)num_records_to_send;


+(NSDictionary*)mongoSettings;

+(NSString*)mongoHost;
+(NSString*)mongoPassword;
+(NSString*)mongoUser;
+(NSString*)mongoPort;
+(NSString*)mongoName;
+(NSString*)mongoCollection;
+(void) create_bson_from_action_string:(NSString*) action_string bson_obj:(bson*)bson_obj;



@end
