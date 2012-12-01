//
//  RemoveWindowController.m
//  PasswordSaver
//
//  Created by GuoJing on 12-12-1.
//
//

#import "RemoveWindowController.h"

@implementation RemoveWindowController

@synthesize remove_panel;
@synthesize remove_field;
@synthesize remove_button;

-(id)init{
    [super init];
    helper = [[SqliteHelper alloc] init];
    return self;
}

-(IBAction)onRemoveButtonClicked:(id)sender{
    [helper connect];
    [helper removeKey:remove_field.title];
    [[self remove_panel] orderOut:sender];
    self.remove_field.title = @"";
}

-(void)dealloc{
    [helper release];
    [super dealloc];
}

@end
