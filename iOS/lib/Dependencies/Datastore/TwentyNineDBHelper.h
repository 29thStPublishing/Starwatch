//
//  TwentyNineDBHelper.h
//  PadThai
//
//  Created by Natalie Podrazik on 6/2/12.
//  Copyright (c) 2012 29th Street Publishing. All rights reserved.
//

#import "FMDatabase.h"

@interface TwentyNineDBHelper : FMDatabase

/** Private methods work with one open (specified) database **/
-(id)initialize:(NSString*)dbName;


-(NSDictionary*)queryForCols:(int)object_id 
                       table:(NSString*)table;

-(NSMutableArray*)queryForColsWithClause:(NSArray*)columnsWanted
                                   table:(NSString*)table 
                             whereClause:(NSString*)whereClause 
                            sortByClause:(NSString*)sortByClause;

-(int)insertQuery:(NSMutableArray*)columns 
           values:(NSMutableArray*)values 
            table:(NSString*)table;

-(void)updateQuery:(NSMutableArray*)columns 
            values:(NSMutableArray*)values 
             table:(NSString*)table 
         object_id:(int)object_id;

-(void)deleteRecordsForCondition:(NSString*)table 
                       condition:(NSString*)condition;

-(int)getCountForTable:(NSString*)table 
             condition:(NSString*)condition;


-(void)log:(NSString*)table 
  metadata:(NSString*)metadata;

/** Public methods **/

+(NSDictionary*)queryForCols:(NSString*)dbName 
                   object_id:(int)object_id 
                       table:(NSString*)table;

+(NSMutableArray*)queryForColsWithClause:(NSString*)dbName 
                           columnsWanted:(NSArray*)columnsWanted 
                                   table:(NSString*)table 
                             whereClause:(NSString*)whereClause 
                            sortByClause:(NSString*)sortByClause;

+(int)insertQuery:(NSString*)dbName
          columns:(NSMutableArray*)columns 
           values:(NSMutableArray*)values 
            table:(NSString*)table;

+(void)updateQuery:(NSString*)dbName
           columns:(NSMutableArray*)columns 
            values:(NSMutableArray*)values 
             table:(NSString*)table 
         object_id:(int)object_id;

+(int) getCountForTable:(NSString*)dbName
                  table:(NSString*)table 
              condition:(NSString*)condition;

+(void)deleteRecordsForCondition:(NSString*)dbName
                           table:(NSString*)table 
                       condition:(NSString*)condition;


-(void)log:(NSString*)table 
  metadata:(NSString*)metadata;

// other utilities.
+(void)dumpDictionary:(NSDictionary*)dictionary;
+(void)dumpArray:(NSArray*)array;


+(void)createEditableCopyofDatabaseIfNeeded:(NSString*)dbName forceOverwrite:(BOOL)forceOverwrite;



+(void)arrayForKeys:(NSDictionary*)dictionary keys:(NSMutableArray*)keys values:(NSMutableArray*)values;


+(NSString*)stringifyArray:(NSMutableArray*)array ;

+(NSString*)escapeString:(NSString*)original;
+(NSString*)createUpdateChain:(NSMutableArray*)columns values:(NSMutableArray*)values separator:(NSString*)separator;


+(BOOL)ensureKeyValue:(NSString*)dbName 
                  key:(NSString*)key 
                value:(NSString*)value;

+(NSString*)wrapInSingleQuotes:(NSString*)original;
    
@end
