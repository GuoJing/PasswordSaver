//
//  AddWindowController.m
//  PasswordSaver
//
//  Created by GuoJing on 12-11-28.
//
//

#import "AddWindowController.h"

@implementation AddWindowController

@synthesize key_textfield;
@synthesize pwd_textfield;
@synthesize decs_textfield;
@synthesize done_button;
@synthesize error_textfield;
@synthesize loading_resc;
@synthesize add_panel;

-(id)init{
    [super init];
    helper = [[SqliteHelper alloc] init];
    return self;
}

-(IBAction)onAddButtonClicked:(id)sender{
    BOOL is_key_not_entered=[key_textfield.title isEqual:@""];
    BOOL is_pwd_not_entered=[pwd_textfield.title isEqual:@""];
    if(is_key_not_entered||is_pwd_not_entered)
    {
        error_textfield.title=@"Please input all the text field.";
    }
    else
    {
        [loading_resc setHidden:FALSE];
        [loading_resc setDisplayedWhenStopped:NO];
        [loading_resc startAnimation:sender];
        //insert into db
        [helper connect];
        
        if(![helper checkKey:key_textfield.title])
        {
            [helper insertKey:key_textfield.title insertPwd:pwd_textfield.title insertDesc:decs_textfield.title];
            [loading_resc stopAnimation:sender];
            [loading_resc setHidden:TRUE];
            [add_panel orderOut:sender];
            [self emptyTextField:sender];
        }
        else
        {
            [loading_resc stopAnimation:sender];
            [loading_resc setHidden:TRUE];
            error_textfield.title=@"Already the same key.";
        }
        
        [helper disconnect];
    }
}

-(IBAction)emptyTextField:(id)sender{
    key_textfield.title=@"";
    pwd_textfield.title=@"";
    decs_textfield.title=@"";
    error_textfield.title=@"";
    NSLog(@"open window");
}

@end
