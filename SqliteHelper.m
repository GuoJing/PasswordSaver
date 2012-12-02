//
//  SqliteHelper.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-3.
//  Copyright 2010 GuoJingMe. All rights reserved.
//

#import "SqliteHelper.h"
#import "Consts.h"
#import "lib/db/FMDatabase.h"
#import "lib/db/FMDatabaseAdditions.h"
#import "lib/db/FMResultSet.h"
#import "lib/crypto/crypto.h"

@implementation SqliteHelper

@synthesize database;
@synthesize db;
@synthesize prefs;

-(NSString*)getFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:kFileName];
    return path;
}

-(BOOL)connect{
    NSString *path = [self getFilePath];
    [path retain];
    prefs = [NSUserDefaults standardUserDefaults];
    db = [FMDatabase databaseWithPath:path];
    if (![db open]) {
        [db release];
        NSLog(@"Open db error!");
        return NO;
    }
    NSLog(@"Open db success!");
    
    if (![db tableExists:kDbName]) {
        NSLog(@"create table");
        [db executeUpdate:@"create table if not exists password_saver (key text not null,pwd,desc text)"];
    };
    [path release];
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
    NSData * nkey = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *code = [self stringWithEncode:nkey];
    [db executeUpdate:@"insert into password_saver (key,pwd,desc) values (?,?,?)", key, code, description];
    [db commit];
    return YES;
}

-(BOOL)removeKey:(NSString*) key {
    [db executeUpdate:@"delete from password_saver where key = ?", key];
    [db commit];
    return YES;
}

-(BOOL)checkKey:(NSString*) key{
    FMResultSet *results = [db executeQuery:@"select * from password_saver where key=?", key];
    if([results next]){
        return YES;
    }
    return NO;
}

-(NSString*)checkPwd:(NSString*) key{
    FMResultSet *results = [db executeQuery:@"select * from password_saver where key=?", key];
    NSLog(@"Search password by key %@", key);
    while ([results next]) {
        NSData *code = [results dataForColumn:@"pwd"];
        NSLog(@"password is %@", code);
        code = [self stringWithDecode:code];
        NSString* pwd = [[NSString alloc] initWithData:code encoding:NSUTF8StringEncoding];
        NSLog(@"password is %@", pwd);
        [results close];
        return pwd;
    };
    return @"N";
}

-(NSMutableArray*)getValues:(NSString*) key{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sql = [[NSString alloc] initWithFormat:@"select key,desc from password_saver where key like '%%%@%%'",key];
    if ([key isEqualToString:@""]) {
        sql = [[NSString alloc] initWithFormat:@"select key,desc from password_saver"];
    }
    FMResultSet *results = [db executeQuery:sql];
    while ([results next]){
        NSString *keyValue = @"Secret";
        NSString * pwdValue = @"";
        NSString *descValue = [results stringForColumn:@"desc"];
        KeyModel *keyModel = [[KeyModel alloc] initWithKey:keyValue initWithPassword:pwdValue initWithDescription:descValue];
        [array addObject:keyModel];
    };
    return array;
}

-(NSData*)stringWithEncode:(NSData*) nkey{
    CCAlgorithm algo = kCCAlgorithmAES128;
	CCOptions opts = kCCOptionPKCS7Padding;
	NSString * iv = nil;
    CCCryptorStatus status = kCCSuccess;
    nkey = [nkey dataEncryptedUsingAlgorithm: algo
                                         key: kKey
                        initializationVector: iv
                                     options: opts
                                       error: &status];
    NSLog(@"Encode to %@", nkey);
    return nkey;
}

-(NSData*)stringWithDecode:(NSData*) nkey{
    CCAlgorithm algo = kCCAlgorithmAES128;
	CCOptions opts = kCCOptionPKCS7Padding;
	NSString * iv = nil;
    CCCryptorStatus status = kCCSuccess;
    nkey = [nkey decryptedDataUsingAlgorithm: algo
                                         key: kKey
                        initializationVector: iv
                                     options: opts
                                       error: &status];
    return nkey;
}
@end
