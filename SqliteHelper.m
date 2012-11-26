//
//  SqliteHelper.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-3.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SqliteHelper.h"
#import "Consts.h"
#import "lib/db/FMDatabase.h"
#import "lib/db/FMDatabaseAdditions.h"
#import "lib/db/FMResultSet.h"

@implementation SqliteHelper

@synthesize database;
@synthesize db;

-(BOOL)connect{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:kFileName];
    db = [FMDatabase databaseWithPath:path];
    if (![db open]) {
        [db release];
        NSLog(@"Open db error!");
        return NO;
    }
    NSLog(@"Open db success!");
    
    if (![db tableExists:kDbName]) {
        NSLog(@"create table");
        [db executeUpdate:@"create table if not exists password_saver (key text,pwd text,desc text)"];
    };
    
    return YES;
}

-(BOOL)disconnect{
    [db close];
    return YES;
}

-(BOOL)insertKey:(NSString*) key insertPwd:(NSString*) password insertDesc:(NSString*) description{
    if ([key isEqualToString:(@"")]) {
        return NO;
    };
    [db executeUpdate:@"insert into password_saver (key,pwd,desc) values (?,?,?)", key,password,description];
    [db commit];
    return YES;
}

-(BOOL)removeKey:(NSString*) key {
    return YES;
}

-(BOOL)checkKey:(NSString*) key{
    FMResultSet *results = [db executeQuery:@"select * from password_saver where key=?", key];
    NSLog(@"Search password by key");
    while ([results next]) {
        [results close];
        return YES;
    };
    return NO;
}

-(NSString*)checkPwd:(NSString*) key{
    FMResultSet *results = [db executeQuery:@"select * from password_saver where key=?", key];
    NSLog(@"Search password by key %@", key);
    while ([results next]) {
        NSString *pwd = [results stringForColumn:@"pwd"];
        NSLog(@"password is %@", pwd);
        [results close];
        return pwd;
    };
    return @"N";
}

-(NSMutableArray*)getValues:(NSString*) key{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sql = [[NSString alloc] initWithFormat:@"select key,desc,pwd from password_saver where key like '%@%%'",key];
    if ([key isEqualToString:@""]) {
        sql = [[NSString alloc] initWithFormat:@"select key,desc,pwd from password_saver"];
    }
    FMResultSet *results = [db executeQuery:sql];
    while ([results next]){
        NSString *keyValue = [results stringForColumn:@"key"];
        NSString *descValue = [results stringForColumn:@"desc"];
        NSString *pwdValue = [results stringForColumn:@"pwd"];
        KeyModel *keyModel = [[KeyModel alloc] initWithKey:keyValue initWithPassword:pwdValue initWithDescription:descValue];
        [array addObject:keyModel];
    };
    return array;
}

@end
