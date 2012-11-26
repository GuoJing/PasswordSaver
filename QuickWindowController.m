//
//  QuickWindowController.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QuickWindowController.h"


@implementation QuickWindowController

@synthesize self_panel;
@synthesize pwd_key_field;
@synthesize error_textfield;

-(id)init{
    NSLog(@"quick window called");
    [super init];
    helper = [[SqliteHelper alloc] init];
    return self;
}

-(void)awakeFromNib{
    [[self self_panel] makeKeyAndOrderFront:self_panel];
}

-(IBAction)onSearchEnd:(id)sender{
    [helper connect];
    NSString *pwd = [helper checkPwd:pwd_key_field.title];
    [pwd retain];
    if(pwd && [pwd isEqualToString:@"N"])
        //if([pwd isEqualToString:@"N"])
    {
        error_textfield.title = @"No password";
    }
    else {
        [[NSPasteboard  generalPasteboard] declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner:nil];
        [[NSPasteboard  generalPasteboard] setString: pwd forType: NSStringPboardType];
        [self_panel close];
    }
    [pwd release];
    [helper disconnect];
    return;
}

@end
