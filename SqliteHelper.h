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
#import "Consts.h"
#import "lib/db/FMDatabase.h"

@interface SqliteHelper : NSObject {
    sqlite3 *database;
    FMDatabase *db;
}

@property (nonatomic) sqlite3 *database;
@property (assign) FMDatabase *db;

-(BOOL)createConnectionToTable;
-(BOOL)insertKey:(NSString*) key insertPwd:(NSString*) password insertDesc:(NSString*) description;
-(BOOL)removeKey:(NSString*) key;
-(BOOL)checkKey:(NSString*) key;
-(NSString*)checkPwd:(NSString*) key;
-(NSMutableArray*)getValues:(NSString*) key;
@end
