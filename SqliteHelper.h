//
//  SqliteHelper.h
//  PasswordSaver
//
//  Created by GuoJing on 10-5-3.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "KeyModel.h"

#define kFileName @"saver.sql"

@interface SqliteHelper : NSObject {
    sqlite3 *database;
}

@property (nonatomic) IBOutlet sqlite3 *database;

-(BOOL)createConnectionToTable;
-(BOOL)insertKey:(NSString*) key insertPwd:(NSString*) password insertDesc:(NSString*) description;
-(BOOL)checkKey:(NSString*) key;
-(NSString*)checkPwd:(NSString*) key;
-(NSMutableArray*)getValues:(NSString*) key;
@end
