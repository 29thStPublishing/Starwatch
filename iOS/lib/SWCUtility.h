//
//  SWCUtility.h
//  StarWatch
//
//  Created by Natalie Podrazik on 1/17/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWCUtility : NSObject {
    
}



+(BOOL) send_stats;
+(BOOL) actions_to_stderr;

+(NSDictionary*)buildLogDictionary:(NSString*)name 
                         global_id:(NSString*)global_id
                            action:(NSString*)action  
                          metadata:(NSString*)metadata;

+(void)logAction:(NSString*)name
          action:(NSString*)action
       global_id:(NSString*)global_id
        metadata:(NSString*)metadata;


+(void)logError:(NSString*)name
          action:(NSString*)action
       global_id:(NSString*)global_id
        metadata:(NSString*)metadata;

+(void)logDictionary:(NSDictionary*)meta_dictionary;
+(void)logString:(NSString*)metadata;

+(void)deleteBatchRecords:(NSMutableArray*)records;

+(void)logAppStart;
+(void)logAppEnd;
+(void)logAppActive;
+(void)logAppCrash;
+(void)logInfo:(NSDictionary*)customInfo;
+(int)getNumOpens;
+(NSString*)databaseName;

+(void)incrementNumOpens;

+(void)confirmCustomDeviceIDExists;

+(NSString*)createCustomDeviceIDString;

+(NSString*)getUniqueDeviceID;
+(int)num_records;

+(NSMutableArray*)getOlderLogRecords:(int)num_records;

// execute the sending of data.
+(void)send_data;

+(void)begin;

@end

/*** Views  - Defined by the client app.***/
#define SW_VIEW_APP_DELEGATE            @"app_delegate"




/*** Actions ***/
#define SW_ACTION_INFO                  @"info"

#define SW_ACTION_BECAME_ACTIVE         @"became_active"
#define SW_ACTION_CRASH                 @"crash"
#define SW_ACTION_CLICKED_ON_TEXT_LINK  @"clicked_on_text_link"
#define SW_ACTION_DOWNLOAD_BEGIN        @"download_begin"
#define SW_ACTION_DOWNLOAD_COMPLETE     @"download_complete"
#define SW_ACTION_DOWNLOAD_ERROR        @"download_error"
#define SW_ACTION_ENTERED_BACKGROUND    @"entered_background"
#define SW_ACTION_FEEDBACK              @"feedback"
#define SW_ACTION_ERROR                 @"error"
#define SW_ACTION_INSERT_ISSUE          @"insert_issue"
#define SW_ACTION_LOAD_WEBPAGE          @"load_webpage"
#define SW_ACTION_MEMORY_WARNING        @"memory_warning"
#define SW_ACTION_NOTIFICATION          @"notification"
#define SW_ACTION_PRESS_BUTTON          @"press_button"
#define SW_ACTION_PURCHASE_CANCEL       @"purchase_cancel"
#define SW_ACTION_PURCHASE_BEGIN        @"purchase_begin"
#define SW_ACTION_PURCHASE_SUCCESS      @"purchase_success"
#define SW_ACTION_PUSH_TOKEN_RECEIVED   @"push_token_received"
#define SW_ACTION_PUSH_TOKEN_SENT       @"push_token_sent"
#define SW_ACTION_PUSH_NOTIFICATION_RECEIVED  @"push_notification_received"
#define SW_ACTION_RESTORE_BEGIN         @"restore_begin"
#define SW_ACTION_RESTORE_ERROR         @"restore_error"
#define SW_ACTION_RESTORE_SUCCESS       @"restore_success"
#define SW_ACTION_ROTATE                @"rotate"
#define SW_ACTION_SCROLLED              @"scrolled"
#define SW_ACTION_SCROLLED_TO_BOTTOM    @"scrolled_to_bottom"
#define SW_ACTION_SCROLLED_TO_TOP       @"scrolled_to_top"
#define SW_ACTION_SWIPE                 @"swipe"
#define SW_ACTION_SWIPE_UP              @"swipe_up"
#define SW_ACTION_SWIPE_RIGHT           @"swipe_right"
#define SW_ACTION_SWIPE_DOWN            @"swipe_down"
#define SW_ACTION_SWIPE_LEFT            @"swipe_left"
#define SW_ACTION_SWIPE_TWO_FINGERS     @"two_finger_swipe"
#define SW_ACTION_SHARE_SUCCESS         @"share_success"
#define SW_ACTION_SHARE_CANCEL          @"share_cancel"
#define SW_ACTION_SHOW_TEXT             @"show_text"
#define SW_ACTION_HIDE_TEXT             @"hide_text"
#define SW_ACTION_START_APP             @"start_app"
#define SW_ACTION_TAP                   @"tap"
#define SW_ACTION_TAPPED_TOP            @"tapped_top"
#define SW_ACTION_TERMINATED            @"terminated"
#define SW_ACTION_VIEW_BEGIN            @"view_begin"
#define SW_ACTION_VIEW_COMPLETE         @"view_complete"
#define SW_ACTION_WARNING               @"warning"
#define SW_ACTION_WENT_INACTIVE         @"went_inactive"









