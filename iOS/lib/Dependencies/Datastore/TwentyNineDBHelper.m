//
//  TwentyNineDBHelper.m
//  PadThai
//
//  VERSION 1.0
//

#import "TwentyNineDBHelper.h"
#import "SWConstants.h"

@implementation TwentyNineDBHelper


-(id)initialize:(NSString*)dbName {
    
    //NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString * documentsDirectory = [paths objectAtIndex:0];
    
    
    NSArray * docPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cacheDir = [docPaths objectAtIndex:0];
    
    //NSString * path = [documentsDirectory stringByAppendingPathComponent:[PadThaiDatastoreUtility databaseName]];
    
    NSString * path = [cacheDir stringByAppendingPathComponent:dbName];
    
    self = [super initWithPath:path];
    
    return self;
}


-(int)getCountForTable:(NSString*)table condition:(NSString*)condition {
    if (![self open]) {
        return 0;
    }
    
    int count = 0;
    
    NSString * query = [NSString stringWithFormat:@"select count(*) from %@", table];
    
    // include the condition if there is one.
    if (condition != nil) {
        query = [NSString stringWithFormat:@"%@ where %@", query, condition];
    }
    
    // finally, end the query in a semi-colon.
    query = [NSString stringWithFormat:@"%@;", query];
    
    
    FMResultSet * t = [self executeQuery:query];
    
    if ([t next]) {
        count = [t intForColumnIndex:0];
    }
    
    [t close];
    
    return count;
}

-(void)deleteRecordsForCondition:(NSString*)table condition:(NSString*)condition {
    if (![self open]) {
        NSLog(@"[deleteRecordsForCondition] Could not open self; returning.");
        return;
    }
    
    NSString * query = [NSString stringWithFormat:@"delete from %@ where %@;",
                        table, condition];
    
    
    // NSLog(@"[deleteRecordsForCondition] q = %@\n", query);
    BOOL result = [self executeUpdate:query];
    
    if (!result) {
        NSLog(@"Error %@ - %d", [self lastErrorMessage], [self lastErrorCode]);
    }
    
    return;
}



-(void)log:(NSString*)table 
  metadata:(NSString*)metadata {
    if (![self open]) {
        return;
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    NSDate * now = [NSDate dateWithTimeIntervalSinceNow:0];
    
    
    NSString * insertString = [NSString stringWithFormat:@"insert into %@ (last_updated, metadata) values ('%@', '%@');", 
                               table,
                               [formatter stringFromDate:now],
                               metadata];
        
    BOOL result = [self executeUpdate:insertString];
    
    if (!result) {
        NSLog(@"Error %@ - %d", [self lastErrorMessage], [self lastErrorCode]);
    }
    
    
    insertString = nil;
    [formatter release];
    formatter = nil;
    return;
}



-(int)insertQuery:(NSMutableArray*)columns values:(NSMutableArray*)values table:(NSString*)table {
    if (![self open]) {
        NSLog(@"[insertQuery] Could not open self; returning\n");
        return 0;
    }
    
    /*
     NSLog(@"\n COLUMNS: \n");
     [TwentyNineDBHelper dumpArray:columns];
     NSLog(@"\n VALUEs: \n");
     [TwentyNineDBHelper dumpArray:values];
     */
    
    
    NSString * cols = [TwentyNineDBHelper stringifyArray:columns];
    NSString * vals = [TwentyNineDBHelper stringifyArray:values];
    
    NSString * query = [NSString stringWithFormat:@"insert into %@ (%@) values (%@);",
                        table, 
                        cols,
                        vals];
    
    // warning: this prints a lot to stderr!
    //NSLog(@"\n\n[insertQuery] query = %@\n", query);
    
    BOOL result = [self executeUpdate:query];
    
    if (!result) {
        //NSLog(@"Error - %@ - %@", [self lastErrorMessage], [self lastErrorCode]);
        NSLog(@"Error - %@\n", [self lastErrorMessage]);
    }
    
    // then, get the record you just inserted.    
    
    return 1;
}


-(void)updateQuery:(NSMutableArray*)columns values:(NSMutableArray*)values table:(NSString*)table object_id:(int)object_id {
    if (![self open]) {
        NSLog(@"[updateQuery] Could not open self; returning\n");
        return;
    }
    
    // Make sure that the cols & vals counts are equal.
    if ([columns count] != [values count]) {
        NSLog(@"[updateQuery] Cannot match values to columns; inequal array lengths.  Returning.\n");
        return;
    }
    
    
    // example update query:
    //  "update issue set title='%@', description='%@' where id=%d;",     
    NSString * update_chain = [TwentyNineDBHelper createUpdateChain:columns values:values separator:@","];    
    
    
    NSString * query = [NSString stringWithFormat:@"update %@ set %@ where id=%d;",
                        table, 
                        update_chain,
                        object_id];
    
    // NSLog(@"[updateQuery] query = %@\n", query);
    
    BOOL result = [self executeUpdate:query];
    
    if (!result) {
        NSLog(@"Error - %@", [self lastErrorMessage]);
    }
    
    return;
    
}



-(NSMutableArray*)queryForColsWithClause:(NSArray*)columnsWanted table:(NSString*)table whereClause:(NSString*)whereClause sortByClause:(NSString*)sortByClause {
    if (![self open]) {
        NSLog(@"[queryForColsWithClause] Could not open self; returning.\n");
        return nil;
    }
    
    
    NSMutableArray * result = nil;
    
    if ([columnsWanted count] <= 0) {
        return nil;
    }
    
    
    // make the last item first.
    NSString * cols =  [NSString stringWithFormat:@"%@", [columnsWanted objectAtIndex:([columnsWanted count] - 1)]];
    
    
    // then, for each additional, prepend it with a comma.
    for (int i = ([columnsWanted count] - 2); i >= 0; i--) {
        cols = [NSString stringWithFormat:@"%@, %@", [columnsWanted objectAtIndex:i], cols];
    }
    
    
    // first, get the count.
    NSString * secondHalfOfQuery;
    
    if (whereClause != nil) {
        secondHalfOfQuery = [NSString stringWithFormat:@"%@ where %@ order by %@",
                             table, 
                             whereClause,
                             sortByClause];
    }
    else {
        secondHalfOfQuery = [NSString stringWithFormat:@"%@ order by %@",
                             table, 
                             sortByClause]; 
    }
    
    NSString * query = [NSString stringWithFormat:@"select count(*) from %@;",
                        secondHalfOfQuery];
    
    
    // NSLog(@"[queryForColsWithClause ] query = %@\n", query);
    FMResultSet * s = [self executeQuery:query];
    int capacity = 0;
    
    if ([s next]) {
        capacity = [s intForColumnIndex:0];
    }    
    
    
    // then, execute the real query.
    
    query = [NSString stringWithFormat:@"select %@ from %@",
             cols, 
             secondHalfOfQuery];
    
    
    //NSLog(@"[queryForColsWithClause] query = %@\n", query);

    
    result = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    
    FMResultSet * t = [self executeQuery:query];
    
    
    while ([t next]) {        
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:[t columnCount]];
        
        for ( int i = 0; i < [t columnCount]; i++) {
            [dict setObject:[t stringForColumnIndex:i] forKey:[t columnNameForIndex:i]];
        }
        
        //[result addObject:[dict copy]];
        [result addObject:dict];
        
        [dict release];
    }
    
    if ([result count] == 0) {
        [result release];
        return nil;
    }
//    return [result autorelease];
    return result;
}



-(NSDictionary*)queryForCols:(int)object_id table:(NSString*)table{
    if (![self open]) {
        NSLog(@"[queryForCols] Could not open self; returning.\n");
        return nil;
    }
    
    NSDictionary * result = nil;
    
    NSString * query = [NSString stringWithFormat:@"select * from %@ where id=%d;", table, object_id];
    
    
    // NSLog(@"\t [queryForCols] query = %@\n", query);
    FMResultSet * s = [self executeQuery:query];
    
    if ([s next]) {
        NSMutableArray * columns = [[NSMutableArray alloc] initWithCapacity:[s columnCount]];
        NSMutableArray * values  = [[NSMutableArray alloc] initWithCapacity:[s columnCount]];
        
        for (int i = 0; i < [s columnCount]; i++) {
            
            /*
             NSLog(@"[%d] col = %@ \t value = %@\n", 
             i,
             [s columnNameForIndex:i], 
             [s stringForColumnIndex:i]);
             */
            
            NSString * val;
            if ([s stringForColumnIndex:i] == nil) {
                val = @"";
            }
            else {
                val = [s stringForColumnIndex:i];
            }
            
            
            [columns addObject:[s columnNameForIndex:i]];
            [values addObject:val];
            
        }
        
        result = [[NSDictionary alloc] initWithObjects:values forKeys:columns];
        
        [columns release];
        [values release];
        
    }
    else{ 
        // NSLog(@"[queryForCols] No Results.\n");
    }
    
    [s close];
    
    
    //return [result autorelease];    
    return result;
}


+(NSMutableArray*)queryForColsWithClause:(NSString*)dbName 
                           columnsWanted:(NSArray*)columnsWanted 
                                   table:(NSString*)table 
                             whereClause:(NSString*)whereClause 
                            sortByClause:(NSString*)sortByClause {
    
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    
    NSMutableArray * result = nil;
    
    if (![database open]) {
        NSLog(@"[queryForColsWithClause] Could not open database.\n");
        //[database release];
    }
    else {
        result = [database queryForColsWithClause:columnsWanted table:table whereClause:whereClause sortByClause:sortByClause];
    }
    
    [database close];
    
    return result;
    
    
}


+(NSDictionary*)queryForCols:(NSString*)dbName 
                   object_id:(int)object_id 
                       table:(NSString*)table {
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    
    NSDictionary * result = nil;
    
    if (![database open]) {
        NSLog(@"[queryForCols] Could not open database.\n");
        [database release];
    }
    else {
        result = [database queryForCols:object_id table:(NSString*)table];
    }
    
    [database close];
    
    return result;
}

+(int)insertQuery:(NSString*)dbName
          columns:(NSMutableArray*)columns 
           values:(NSMutableArray*)values 
            table:(NSString*)table {
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    
    int response = 0;
    
    if (![database open]) {
        NSLog(@"[insertQuery] Could not open database.\n");
        [database release];
    }
    else {
        response = [database insertQuery:columns values:values table:table];
    }
    
    [database close];
        
    return response;
}


+(void)updateQuery:(NSString*)dbName
           columns:(NSMutableArray*)columns 
            values:(NSMutableArray*)values 
             table:(NSString*)table 
         object_id:(int)object_id {
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    
    if (![database open]) {
        NSLog(@"[updateQuery] Could not open database.\n");
        [database release];
    }
    else {
        [database updateQuery:columns values:values table:table object_id:object_id];
    }
    
    [database close];
    
    return;
}




+(void)deleteRecordsForCondition:(NSString*)dbName
                           table:(NSString*)table 
                       condition:(NSString*)condition {
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    
    if (![database open]) {
        NSLog(@"[deleteRecordsForCondition] Could not open database.\n");
        [database release];
    }
    else {
        [database deleteRecordsForCondition:table condition:condition];
    }
    
    [database close];
    
    return;
}


+(int) getCountForTable:(NSString*)dbName
                  table:(NSString*)table 
              condition:(NSString*)condition {
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    int result = 0;
    
    if (![database open]) {
        NSLog(@"[getCountForTable] Could not open database.\n");
        [database release];
    }
    else {
        result = [database getCountForTable:table condition:condition];
    }
    
    [database close];
    
    return result;
    
}

+(void)log:(NSString*)dbName
     table:(NSString*)table
  metadata:(NSString*)metadata {
    TwentyNineDBHelper * database = [[[TwentyNineDBHelper alloc] initialize:dbName] autorelease];
    
    if (![database open]) {
        [database release];
        return;
    }
    else {
        [database log:dbName metadata:metadata];
    }
    
    [database close];
    
    return ;
}
+(void)dumpDictionary:(NSDictionary*)dictionary {
    NSEnumerator *enumerator = [dictionary keyEnumerator];
    
    id key;
    
    NSLog(@"---- DICTIONARY DUMP BEGINNING ---- ");
    
    while ((key = [enumerator nextObject])){
        
        NSLog(@"\n\n ----KEY: %@ ------ \n%@", key, [dictionary objectForKey: key]);
    }
    
    NSLog(@"---- DICTIONARY DUMP COMPLETE. ---- ");
    
}

+(void)dumpArray:(NSArray*)array {   
    
    NSLog(@"---- ARRAY DUMP BEGINNING ---- ");
    
    for (int i = 0; i < [array count]; i++) {
        NSLog(@"\n\n ----INDEX: %d ------ \n%@", i, [array objectAtIndex:i]);
    }
    
    NSLog(@"---- ARRAY DUMP COMPLETE. ---- ");
}

+(void)arrayForKeys:(NSDictionary*)dictionary keys:(NSMutableArray*)keys values:(NSMutableArray*)values {
    for (int i = 0 ; i < [keys count]; i++) {
        id v = [dictionary objectForKey:[keys objectAtIndex:i]];        
        
        
        if ([v isKindOfClass:[NSString class]]) {
            [values addObject:[NSString stringWithFormat:@"'%@'", [TwentyNineDBHelper escapeString:(NSString*)v]]];
        }
        else {
            [values addObject:[NSString stringWithFormat:@"%d", v]];
        }
    }
}

+(NSString*)escapeString:(NSString*)original {
    NSArray * escapeStrings = [NSArray arrayWithObjects:@"'", nil];
    
    if (![original isKindOfClass:[NSString class]]) {
        return original;
    }
    
    for (int i = 0; i < [escapeStrings count]; i++) {
        NSString * newString = [NSString stringWithFormat:@"'%@", [escapeStrings objectAtIndex:i]];
        original = [original stringByReplacingOccurrencesOfString:[escapeStrings objectAtIndex:i] withString:newString];
    }
    
    return original;
}





// The array elements need 'quotes' around them if they're values and strings.
// This function won't add those.
+(NSString*)stringifyArray:(NSMutableArray*)array {
    // make the last item first.
    NSString * result =  [NSString stringWithFormat:@"%@", [array objectAtIndex:([array count] - 1)]];
    
    if ([array count] > 1) {
        // then, for each additional, prepend it with a comma.
        for (int i = ([array count] - 2); i >= 0; i--) {
            result = [NSString stringWithFormat:@"%@, %@", [array objectAtIndex:i], result];
        }
    }
    
    return result;
}

// makes a list like title='%@', description='%@'.
+(NSString*)createUpdateChain:(NSMutableArray*)columns values:(NSMutableArray*)values separator:(NSString *)separator{
    NSString * update_chain = [NSString stringWithFormat:@"%@=%@", 
                               [columns objectAtIndex:([columns count] - 1)],
                               [values objectAtIndex:([values count] - 1)]];
    
    if ([columns count] > 1) {
        // then, for each additional, prepend it with a comma.
        for (int i = ([columns count] - 2); i >= 0; i--) {
            update_chain = [NSString stringWithFormat:@"%@=%@%@ %@", 
                            [columns objectAtIndex:i],
                            [values objectAtIndex:i],
                            separator,
                            update_chain];
            
        }
    }
    
    return update_chain;
    
}

+(void)createEditableCopyofDatabaseIfNeeded:(NSString*)dbName forceOverwrite:(BOOL)forceOverwrite{
    // test for existence...
    BOOL success;
    
    //NSString * databaseName = [PadThaiDatastoreUtility databaseName];
    
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;
    //NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString * documentsDirectory = [paths objectAtIndex:0];

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cacheDir = [paths objectAtIndex:0];
    
    NSString * writeableDBPath = [cacheDir stringByAppendingPathComponent:dbName];
    
    NSLog(@"[AppDelegate] writeableDBPath = %@", writeableDBPath);
    
    success = [fileManager fileExistsAtPath:writeableDBPath];
    
    if (success) {
        
        // there is a db at this location - delete it.
        if (!forceOverwrite) {
            return;
        }
        
        // REMOVE THE FILE THAT'S THERE NOW.
        [fileManager removeItemAtPath:writeableDBPath error:&error];

    }
    
    NSString * defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
    success = [fileManager fileExistsAtPath:writeableDBPath];
    
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writeableDBPath error:&error];
    
    NSLog(@"DB Path = %@\n", defaultDBPath);
    
    if (!success) {
        NSAssert1(0, @"Failed to create writeable database file with message '%@'.\n", [error localizedDescription]);
        
        NSLog(@"Failed to create writeable database file with message '%@'.\n", [error localizedDescription]);
        
    }
    
}




+(BOOL)ensureKeyValue:(NSString*)dbName 
                  key:(NSString*)key 
                value:(NSString*)value {
    
    
    NSMutableArray * values = [TwentyNineDBHelper queryForColsWithClause:dbName 

                                                           columnsWanted:[NSArray arrayWithObjects:@"key", @"value", nil]
                                                                   table:@"settings" 
                                                             whereClause:[NSString stringWithFormat:@"key='%@'", key] 
                                                            sortByClause:@"id"];
    
        
    if (values && ([values count] > 0)) {
        NSDictionary * match = [values objectAtIndex:0];
        
        if ([[match objectForKey:@"value"] isEqualToString:value]) {
            return TRUE;
        }
    }
    
    return FALSE;
}

+(NSString*)wrapInSingleQuotes:(NSString*)original {
    if (original == nil) {
        return @"''";
    }
    return [NSString stringWithFormat:@"'%@'", [TwentyNineDBHelper escapeString:original]];
}
@end
