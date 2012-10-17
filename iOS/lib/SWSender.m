//
//  SWSender.m
//  StarWatch
//
//  Created by Natalie Podrazik on 1/18/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import "SWSender.h"

#import "SWCUtility.h"


#import "SWConstants.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "JSONKit.h"

#define MIN_NUM_RECORDS_TO_SEND 10

@implementation SWSender


+(void)sendData {
    
    // if we're not collecting data, don't send it, either.
    if (![SWCUtility send_stats]) {
        NSLog(@"[sendData] We aren't sending stats yet.\n");
        return;
    }

    
    // if we're connected to the internet,
    if (![SWSender hasInternetConnection]) {
        NSLog(@"[sendData] No internet connection.\n");
        return;
    }
    
    
    int num_records = [SWCUtility num_records];
    /*
     if (num_records < MIN_NUM_RECORDS_TO_SEND) {
        //NSLog(@"[sendData] Not enough records to send (%d, min=%d)\n", num_records, MIN_NUM_RECORDS_TO_SEND);
        return;
    }
     */
    
    
    // don't do anything if there aren't any records, hon
    if (num_records < 1) {
        return;
    }
    
    // send the latest N records.
    NSLog(@"[sendData] Ready to send %d records!\n", num_records);
        
    //dispatch_queue_t high_priority_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    //dispatch_sync(high_priority_queue, ^{

        [SWSender sendOldestRecords:num_records];
        NSLog(@"Sending of Starwatch Data Succeeded!\n");
    //});
    
    return;
}


+(void)sendOldestRecords:(int)num_records_to_send {
    
    // step one: get the json snippet to send.
    NSMutableArray * records_to_send = [SWCUtility getOlderLogRecords:num_records_to_send];
    
    if (records_to_send == nil) {
        return;
    }
    
    // step two: attempt to connect to mongo
    mongo conn[1];
    
    
    int status = mongo_connect(conn, [[SWSender mongoHost] UTF8String], atoi([[SWSender mongoPort] UTF8String]));
    

    if( status != MONGO_OK ) {
        // NSLog( @"Error: %d\n", conn->err );
        switch ( conn->err ) {
            case MONGO_CONN_SUCCESS:
                NSLog(@"Mongo connection succeeded\n" );
                break;
        }
        
    }
    else {
        
        
        // step three: authenticate with the mongo service
        bson doc1[1];
        
        mongo_cmd_authenticate( conn, [[SWSender mongoName] UTF8String], 
                               [[SWSender mongoUser] UTF8String],
                               [[SWSender mongoPassword] UTF8String]);

        
        NSMutableArray * objectsToDelete = [[NSMutableArray alloc] initWithCapacity:num_records_to_send];
        
        // step four: for each record, bundle it as bson (mongo's json format), and submit it to mongo.
        for (int i = 0; i < num_records_to_send; i++) {

             bson_init( doc1 );
             
             bson_append_string( doc1, "last_updated", [[[records_to_send objectAtIndex:i] objectForKey:@"last_updated"] UTF8String]);
             
             bson_append_string( doc1, "device", [[[records_to_send objectAtIndex:i] objectForKey:@"device"] UTF8String]);
            
             bson_append_string( doc1, "global_id", [[[records_to_send objectAtIndex:i] objectForKey:@"global_id"] UTF8String]);
                         
             
             NSDictionary * jsonDict = [[[records_to_send objectAtIndex:i] objectForKey:@"action_data"] objectFromJSONString];

             
             bson_append_string( doc1, "view", [[jsonDict objectForKey:@"name"] UTF8String]);
             bson_append_string( doc1, "action", [[jsonDict objectForKey:@"action"] UTF8String]);
             bson_append_string( doc1, "metadata", [[jsonDict objectForKey:@"metadata"] UTF8String]);             
             bson_finish( doc1 );

             
             mongo_insert( conn, [[SWSender mongoCollection] UTF8String], doc1 );
             
             // add this to the delete queue.
             [objectsToDelete addObject:[[records_to_send objectAtIndex:i] objectForKey:@"id"]];             
             
         }
        
        // step five: delete those submitted objects from the database.
        [SWCUtility deleteBatchRecords:objectsToDelete];
        
        objectsToDelete = nil;
    }    
    
    
    records_to_send = nil;

    return;

    
    
}

+(void) create_bson_from_action_string:(NSString *) action_string bson_obj:(bson*)bson_obj {

    bson_init( bson_obj );
    
    // first, translate the string to a dictionary (backwards, I know)
    NSDictionary * jsonDict = [action_string objectFromJSONString];
    
    bson_append_string( bson_obj, "name", [[jsonDict objectForKey:@"name"] UTF8String]);
    bson_append_string( bson_obj, "metadata", [[jsonDict objectForKey:@"metadata"] UTF8String]);
    bson_append_string( bson_obj, "action", [[jsonDict objectForKey:@"action"] UTF8String]);    
    
    bson_finish( bson_obj );
    
    return;

}

+(int)recordCountWorthSending {
    return MIN_NUM_RECORDS_TO_SEND;
}


+(NSString*)mongoHost {
    return [[SWSender mongoSettings] objectForKey:@"db_host"];
}
+(NSString*)mongoPassword {
    return [[SWSender mongoSettings] objectForKey:@"db_password"];

}
+(NSString*)mongoUser {
    return [[SWSender mongoSettings] objectForKey:@"db_user"];

}
+(NSString*)mongoPort {
    return [[SWSender mongoSettings] objectForKey:@"db_port"];

}
+(NSString*)mongoName {
    return [[SWSender mongoSettings] objectForKey:@"db_name"];
}

+(NSString*)mongoCollection {
    return [NSString stringWithFormat:@"%@.%@", 
            [[SWSender mongoSettings] objectForKey:@"db_name"],
            [[SWSender mongoSettings] objectForKey:@"db_collection"]];
}


+(NSDictionary*)mongoSettings {    
    return [SWConstants mongo_settings];
}

// from http://stackoverflow.com/questions/1083701/how-to-check-for-an-active-internet-connection-on-iphone-sdk
+(BOOL)hasInternetConnection {
    
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            
            
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                
                
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                
                return YES;
            }
        }
    }
    
    
    return NO;
    
}



@end
