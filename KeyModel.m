//
//  KeyModel.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "KeyModel.h"


@implementation KeyModel

@synthesize key;
@synthesize password;
@synthesize description;

-(id)init{
    [super init];
    return self;
}

-(id)initWithKey:(NSString*)inkey initWithPassword:(NSString*)inpassword initWithDescription:(NSString*)indescription{
    self.key = inkey;
    self.password = inpassword;
    self.description = indescription;
    return self;
}

-(void)dealloc{
    [self.key release];
    [self.password release];
    [self.description release];
    [super dealloc];
}

@end
