//
//  DBManager.m
//  TH Reader
//
//  Created by Trần Đình Tôn Hiếu on 6/8/19.
//  Copyright © 2019 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "DBManager.h"

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;

@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong) NSMutableArray *resultsArray;

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

@end

@implementation DBManager

-(id)initWithDatabaseFileName:(NSString *)dbFileName {
    self = [super init];
    _databaseFilename = dbFileName;
    return self;
}

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // sqlite3 object
    sqlite3 *sqlite3Database;
    
    // Set the database file path
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString *databasePath =  [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: _databaseFilename]];
    
    // Reset results array
    if (self.resultsArray != nil) {
        [self.resultsArray removeAllObjects];
        self.resultsArray = nil;
    }
    self.resultsArray = [[NSMutableArray alloc] init];
    
    // Reset column names array
    if (self.columnNamesArray != nil) {
        [self.columnNamesArray removeAllObjects];
        self.columnNamesArray = nil;
    }
    self.columnNamesArray = [[NSMutableArray alloc] init];
    
    // Open the database
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // Will be stored the query after having been compiled into a SQLite statement
        sqlite3_stmt *compiledStatement;
        
        
        // Load all data from database to memory
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            // If the query is non-executable.
            if (!queryExecutable){
                
                // Keep the data for each fetched row
                NSMutableArray *dataRowArray;
                
                // Loop through the results and add them to the results array
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Contain the data of a fetched row.
                    dataRowArray = [[NSMutableArray alloc] init];
                    
                    // Total number of columns
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            // Convert the characters to string.
                            [dataRowArray addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        // Keep the current column name.
                        if (self.columnNamesArray.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.columnNamesArray addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    if (dataRowArray.count > 0) {
                        [self.resultsArray addObject:dataRowArray];
                    }
                }
            } else {
                BOOL executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    // Keep the affected rows.
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else {
                    // If could not execute the query show the error message on the debugger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        } else {
            // In the database cannot be opened, write log message
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
        
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
}

-(NSArray *)loadDataFromDB:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
    return (NSArray *)self.resultsArray;
}

-(void)executeQuery:(NSString *)query{
    // Run executable query
     [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

@end
