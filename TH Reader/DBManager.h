//
//  DBManager.h
//  TH Reader
//
//  Created by Trần Đình Tôn Hiếu on 6/8/19.
//  Copyright © 2019 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

@property (nonatomic) NSMutableArray *columnNamesArray;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(id)initWithDatabaseFileName:(NSString *)fileName;

-(NSArray *)loadDataFromDB:(NSString*)query;

-(void)executeQuery:(NSString*)query;

@end

NS_ASSUME_NONNULL_END
