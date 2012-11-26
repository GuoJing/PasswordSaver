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

@implementation SqliteHelper

@synthesize database;
@synthesize db;

-(BOOL)createConnectionToTable{
    NSString *paths = [NSHomeDirectory() stringByAppendingPathComponent:kFilePath];
    paths = [paths stringByAppendingPathComponent:kFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileFinded = [fileManager fileExistsAtPath:paths];
    
    if(fileFinded)
    {
        if(sqlite3_open([paths UTF8String],&database)!=SQLITE_OK)
        {
            sqlite3_close(database);
            NSLog(@"Open Failed");
            return NO;
        }
    }
    else
    {
        if(sqlite3_open([paths UTF8String],&database)!=SQLITE_OK)
        {
            sqlite3_close(database);
            NSLog(@"Open Failed");
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)insertKey:(NSString*) key insertPwd:(NSString*) password insertDesc:(NSString*) description{
    char *errorMsg;
    NSString *createSQL = @"create table if not exists password_saver (key text,pwd text,desc text)";
    if(sqlite3_exec(database,[createSQL UTF8String],NULL,NULL,&errorMsg)!=SQLITE_OK)
    {
        sqlite3_close(database);
        NSLog(@"Open failed or init password_saver");
    }
    
    NSString *insertData = [[NSString alloc] initWithFormat:@"insert into password_saver (key,pwd,desc) values ('%@','%@','%@')",key,password,description];
    if(sqlite3_exec(database,[insertData UTF8String],NULL,NULL,&errorMsg)!=SQLITE_OK)
    {
        sqlite3_close(database);
        return NO;
    }
    NSLog(@"Insert success!");
    return YES;
}

-(BOOL)removeKey:(NSString*) key {
    return YES;
}

-(BOOL)checkKey:(NSString*) key{
    NSString *getUserCountSQL = [[NSString alloc] initWithFormat:@"select * from password_saver where key='%@'",key];
    sqlite3_stmt *statement;
    NSLog(@"Search user");
    
    if(sqlite3_prepare_v2(database,[getUserCountSQL UTF8String],-1,&statement,nil)==SQLITE_OK)
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            int row = sqlite3_column_int(statement,0);
            char* rowData = (char*)sqlite3_column_text(statement,1);
            NSString *fieldName = [[NSString alloc] initWithFormat:@"show%d",row];
            NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];
            NSLog(@"fieldName is :%@,fieldValue is :%@",fieldName,fieldValue);
            [fieldName release];
            [fieldValue release];
            sqlite3_finalize(statement);
            return YES;
        }
    }
    
    return NO;
}

-(NSString*)checkPwd:(NSString*) key{
    NSString *getUserCountSQL = [[NSString alloc] initWithFormat:@"select * from password_saver where key='%@'",key];
    sqlite3_stmt *statement;
    NSLog(@"Search user");
    NSString *ret;
    if(sqlite3_prepare_v2(database,[getUserCountSQL UTF8String],-1,&statement,nil)==SQLITE_OK)
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            int row = sqlite3_column_int(statement,0);
            char* rowData = (char*)sqlite3_column_text(statement,1);
            NSString *fieldName = [[NSString alloc] initWithFormat:@"show%d",row];
            NSString *fieldValue = [[NSString alloc] initWithUTF8String:rowData];
            NSLog(@"fieldName is :%@,fieldValue is :%@",fieldName,fieldValue);
            ret = fieldValue;
            [fieldName release];
            [fieldValue release];
            sqlite3_finalize(statement);
            return [[NSString alloc] initWithFormat:@"%@", ret];
        }
    }
    
    return @"N";
}

-(NSMutableArray*)getValues:(NSString*) key{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *getUserCountSQL = [[NSString alloc] initWithFormat:@"select key,desc,pwd from password_saver where key like '%@%%'",key];
    if ([key isEqualToString:@""]) {
        getUserCountSQL = [[NSString alloc] initWithFormat:@"select key,desc,pwd from password_saver"];
    }
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database,[getUserCountSQL UTF8String],-1,&statement,nil)==SQLITE_OK)
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char* keyData = (char*)sqlite3_column_text(statement,0);
            char* descData = (char*)sqlite3_column_text(statement,1);
            char* pwdData = (char*)sqlite3_column_text(statement,2);
            NSString *keyValue = [[NSString alloc] initWithUTF8String:keyData];
            NSString *descValue = [[NSString alloc] initWithUTF8String:descData];
            NSString *pwdValue = [[NSString alloc] initWithUTF8String:pwdData];
            KeyModel *keyModel = [[KeyModel alloc] initWithKey:keyValue initWithPassword:pwdValue initWithDescription:descValue]; 
            [array addObject:keyModel];
        }
        sqlite3_finalize(statement);
    }
    return array;
}

@end
