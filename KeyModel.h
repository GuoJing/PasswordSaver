//
//  KeyModel.h
//  PasswordSaver
//
//  Created by GuoJing on 10-5-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyModel : NSObject {
    NSString *key;
    NSString *password;
    NSString *description;
}

@property (readwrite, copy) NSString *key;
@property (readwrite, copy) NSString *password;
@property (readwrite, copy) NSString *description;

-(id)initWithKey:(NSString*)key initWithPassword:(NSString*)password initWithDescription:(NSString*)description;
@end
