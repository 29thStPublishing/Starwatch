//
//  SWCUtility.m
//  StarWatch
//
//  Created by Natalie Podrazik on 1/17/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import "SWCUtility.h"
#import "SWCViewController.h"
#import "SWSender.h"

#import "JSONKit.h"

#import "SWConstants.h"

#import "TwentyNineDBHelper.h"


#define STARWATCH_KEY_NUM_OPENS @"STARWATCH-NUM_OPENS"

#define STATS_SETTINGS_TABLE @"settings"
#define SETTINGS_KEY_DEVICE_ID @"device"
#define STARWATCH_LOG_TABLE @"log"

#define IPHONE_4_HEIGHT 480
#define RETINAL_RESOLUTION 2.0


@implementation SWCUtility

+(void)logError:(NSString*)name
         action:(NSString*)action
      global_id:(NSString*)global_id
       metadata:(NSString*)metadata {
    // for now, this is the same as logging an action.
    [self logAction:name
             action:action
          global_id:global_id
           metadata:metadata];
}

+(void)logAction:(NSString*)name
          action:(NSString*)action
       global_id:(NSString*)global_id
        metadata:(NSString*)metadata {
    
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:name global_id:global_id action:action metadata:metadata]];
    
}

// we're going to get all this information from the device.
// note: all the information is in the metadata, which will be parsed out later.
+(void)logInfo:(NSDictionary*)customInfo {
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc] initWithDictionary:customInfo];
    
    [info setObject:[[UIDevice currentDevice] localizedModel]
             forKey:@"device"];
    
    [info setObject:[SWCUtility estimateDeviceType]
             forKey:@"device_version"];
    
    
    [info setObject:[[UIDevice currentDevice] systemVersion]
             forKey:@"ios"];
    
    
    [info setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]
             forKey:@"app_version"];
    
    
    [info setObject:[[NSTimeZone systemTimeZone] name]
             forKey:@"timezone"];
    
    // now this info hunk as metadata.  let the client do more work.
    [SWCUtility logAction:@""
                   action:SW_ACTION_INFO
                global_id:@""
                 metadata:[info JSONString]];

    
    
    
    info = nil;
    
}


+(NSString*)estimateDeviceType {
    NSString * base_model = [[UIDevice currentDevice] localizedModel];
    CGFloat screenScale = [[UIScreen mainScreen] scale];

    
    // iPhone....
    if ([base_model isEqualToString:@"iPhone"]) {
        
        // First hint:
        //  iPhones 4 and below are sized 320x480,
        //  iPhones 5 (and beyond!) are taller.
        CGRect bounds = [[UIScreen mainScreen] bounds];
        
        if (bounds.size.height > IPHONE_4_HEIGHT) {
        
            return [NSString stringWithFormat:@"%@ 5", base_model];
        }
        
        // second hint: iPhones 3 and below are not retinal.
        if (screenScale < 2.0) {
            return [NSString stringWithFormat:@"%@ 3-", base_model];
        }
    
        // otherwise, it's a 4.
        return [NSString stringWithFormat:@"%@ 4", base_model];    
    }


    // otherwise, it's an iPad.
    else if ([base_model isEqualToString:@"iPad"]) {
        // first hint: iPad 1 is the only one that does not have a camera.
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return [NSString stringWithFormat:@"%@ 1", base_model];
        }

        // hint number 2: iPad 2's are not retinal.
        if (screenScale < 2.0) {
            return [NSString stringWithFormat:@"%@ 2", base_model];
        }


        // everything else, we assume it's an iPad 3.
        return [NSString stringWithFormat:@"%@ 3", base_model];
    }
    else if ([base_model isEqualToString:@"iPod touch"]) {
        return base_model;
    }


    return [NSString stringWithFormat:@"%@", base_model];

}


+(NSDictionary*)buildLogDictionary:(NSString*)name 
                         global_id:(NSString*)global_id
                            action:(NSString*)action  
                          metadata:(NSString*)metadata {
    
    // quick parameter check.
    // can't make this an array with objects because one might be nil,
    // defeating the purpose of that efficiency; boo.
    if (name == nil) {
        name = @"";
    }
    
    if (global_id == nil) {
        global_id = @"";
    }
    
    if (action == nil) {
        action = @"";
    }
    
    if (metadata == nil) {
        metadata = @"";
    }
    

    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, 
                                                action,
                                                global_id,
                                                metadata, 
                                                nil]
                                       forKeys:[NSArray arrayWithObjects:@"name", 
                                                @"action", 
                                                @"global_id",
                                                @"metadata",
                                                nil]
            ];
}


/* 
 these actions are special - we always want to look for the same start-up
 and ending strings.
 */
+(void)logAppStart {
    // you can't report orientation data until you load a view.
    
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:SW_VIEW_APP_DELEGATE
                                                   global_id:@""
                                                      action:SW_ACTION_START_APP 
                                                    metadata:@""]];
    
    [SWCUtility incrementNumOpens];
    
    

}

+(void)logAppEnd {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:SW_VIEW_APP_DELEGATE
                                                   global_id:@""
                                                      action:SW_ACTION_ENTERED_BACKGROUND
                                                    metadata:@""]];
    
    [SWSender sendData];
    
}

+(void)logAppCrash {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:SW_VIEW_APP_DELEGATE
                                                   global_id:@""
                                                      action:SW_ACTION_CRASH
                                                    metadata:@""]];
}



+(void)logAppActive {
    [SWCUtility logDictionary:[SWCUtility buildLogDictionary:SW_VIEW_APP_DELEGATE
                                                   global_id:@""
                                                      action:SW_ACTION_BECAME_ACTIVE
                                                    metadata:@""]];
}

+(int)getNumOpens {    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:STARWATCH_KEY_NUM_OPENS] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", 0]
                                                 forKey:STARWATCH_KEY_NUM_OPENS];
        
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:STARWATCH_KEY_NUM_OPENS] intValue];
}

+(void)incrementNumOpens {
    
    int num_opens = [SWCUtility getNumOpens];
    num_opens += 1;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", num_opens]
                                             forKey:STARWATCH_KEY_NUM_OPENS];
}

+(NSString*)databaseName {         
    return [SWConstants database_name];
}


+(void)logDictionary:(NSDictionary*)meta_dictionary {
    
    // write the record translated to json.
           [SWCUtility logString:[meta_dictionary JSONString]];
   
    
    
    /* don't do this asynchronously.
     * 
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
     */
    
    //[SWSender sendData];
    
    //});
}



+(void)logString:(NSString*)metadata {
        

    
    if (![SWConstants collect_stats]) {
        return;
    }
    
    if ([SWCUtility actions_to_stderr]) {
        NSLog(@"\n[SWCUtility] %@\n", metadata);
    }
    
   
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    NSDate * now = [NSDate dateWithTimeIntervalSinceNow:0];
    
    
    // wrap both parameters in single quotes.
    NSString * readableTimestamp = [TwentyNineDBHelper wrapInSingleQuotes:[formatter stringFromDate:now]];
    metadata = [TwentyNineDBHelper wrapInSingleQuotes:metadata];

    NSMutableArray * cols = [NSMutableArray arrayWithObjects:@"last_updated",
                             @"metadata",
                             nil];
    NSMutableArray * vals = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:readableTimestamp, metadata, nil]];
    
    
    
    
        
    [TwentyNineDBHelper insertQuery:[SWCUtility databaseName]
                                                 columns:cols 
                                                  values:vals 
                                                   table:@"log"];
        
        
        
    vals = nil;
    cols = nil;
    
    formatter = nil;

    return;
}



// helpful hint: http://stackoverflow.com/questions/2633801/generate-a-random-alphanumeric-string-in-cocoa
+(NSString*)createCustomDeviceIDString {
    
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int length = 24;
    
    srand(time(0));
    
    
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
    }
    
    NSLog(@"\n Device string = %@\n", randomString);
    
    return randomString;
}


+(NSString*)getUniqueDeviceID {
                  
    // attempting:
    //  select key from settings where key='device';
    
         
    NSMutableArray * device_results = [TwentyNineDBHelper queryForColsWithClause:[SWCUtility databaseName]
                                                                   columnsWanted:[NSArray arrayWithObject:@"value"]
                                                                           table:STATS_SETTINGS_TABLE
                                                                     whereClause:[NSString stringWithFormat:@"key='%@'", SETTINGS_KEY_DEVICE_ID]
                                                                    sortByClause:@"id desc"];
    
    if (device_results == nil) {
        return nil;
    }
    
    NSString * value = [[device_results objectAtIndex:0] objectForKey:@"value"];
    
    device_results = nil;
    
    // otherwise, return the first one.
    return value;

}



+(void)confirmCustomDeviceIDExists {
        
    NSString * query = [SWCUtility getUniqueDeviceID];
    
    // if there are no results, create a new record.
    if (query == nil) {        
        
        NSMutableArray * cols = [NSMutableArray arrayWithObjects:@"key", @"value", nil];
        
        NSMutableArray * vals = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:[TwentyNineDBHelper wrapInSingleQuotes:SETTINGS_KEY_DEVICE_ID],
                                                                       [TwentyNineDBHelper wrapInSingleQuotes:[SWCUtility createCustomDeviceIDString]], nil]];

        
        [TwentyNineDBHelper insertQuery:[SWCUtility databaseName]
                                             columns:cols 
                                              values:vals 
                                               table:STATS_SETTINGS_TABLE];
        
        vals = nil;
        cols = nil;
    }
    
    
    // otherwise, it exists; we're good.
    
    return;    
}


// will return an array of strings, to be repackaged within greater json chunks later.
+(NSMutableArray*)getOlderLogRecords:(int)num_records {
     
    int current_record_count = [SWCUtility num_records];
     
    // in case we're working with just a few records, 
    // readjust the return window.
    if (current_record_count < num_records) {
        num_records = current_record_count;
    }
     
    NSString * device_id = [SWCUtility getUniqueDeviceID];
        
    NSArray * query_results = [TwentyNineDBHelper queryForColsWithClause:[SWCUtility databaseName]
                                                     columnsWanted:[NSArray arrayWithObjects:@"*", nil]
                                                             table:STARWATCH_LOG_TABLE 
                                                       whereClause:nil
                                                      sortByClause:[NSString stringWithFormat:@"id limit %d", num_records]];

        
    if ((query_results != nil) && ([query_results count] > 0)) {
        
        NSMutableArray * packaged_results = [[NSMutableArray alloc] initWithCapacity:[query_results count]];
        for (int i = 0; i < [query_results count]; i++) {
            
            NSDictionary * s = [query_results objectAtIndex:i];
                        
            NSDictionary * metadataObj = [[s objectForKey:@"metadata"] objectFromJSONString];
            
            
            NSArray * objects = [NSArray arrayWithObjects:
                                 [s objectForKey:@"id"], 
                                 [s objectForKey:@"last_updated"],
                                 device_id, 
                                 [s objectForKey:@"metadata"],
                                 [metadataObj objectForKey:@"global_id"],

                                 nil];
            
            NSArray * keys = [NSArray arrayWithObjects:
                              @"id",
                              @"last_updated", 
                              @"device",
                              @"action_data",
                              @"global_id",
                              nil];
            
            [packaged_results addObject:[NSDictionary dictionaryWithObjects:objects                                                 forKeys:keys]];            
        }
        
        query_results = nil;
        
        
        // we should probably free the query results.
        //[query_results release];
        return packaged_results;

    }

         

    return nil;
            
}

+(int)num_records {
    return [TwentyNineDBHelper getCountForTable:[SWCUtility databaseName]
                                          table:@"log" 
                                      condition:nil];
}


+(BOOL) actions_to_stderr {
    return [SWConstants actions_to_stderr];
}

+(void)send_data {
    [SWSender sendData];
}

+(BOOL) send_stats {
    return [SWConstants send_stats];
}

+(void)deleteBatchRecords:(NSMutableArray*)records {
    
    NSMutableString * id_str = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < [records count] - 1; i++) {
        [id_str appendString:[NSString stringWithFormat:@"%@, ", [records objectAtIndex:i]]];
    }
    
    if ([records count] >= 1) {
        [id_str appendString:[NSString stringWithFormat:@"%@", [records objectAtIndex:([records count] - 1)]]];
    }

    
    [TwentyNineDBHelper deleteRecordsForCondition:[SWCUtility databaseName]
                                            table:STARWATCH_LOG_TABLE 
                                        condition:[NSString stringWithFormat:@"id in (%@)", id_str]];
    
    
    return;
}

+(void)begin {
    // Confirms the little Starwatch DB exists and is in the right place for writing.
    [TwentyNineDBHelper createEditableCopyofDatabaseIfNeeded:[SWCUtility databaseName]
                                              forceOverwrite:YES];
    
    // Also confirm that we've generated a unique id for this device.
    [SWCUtility confirmCustomDeviceIDExists];
    
    // increment the number of opens. starts at zero.
    [SWCUtility incrementNumOpens];

}
@end
