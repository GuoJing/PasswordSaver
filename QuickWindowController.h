//
//  QuickWindowController.h
//  PasswordSaver
//
//  Created by GuoJing on 10-5-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SqliteHelper.h"

@interface QuickWindowController : NSPanel {
    IBOutlet NSPanel *self_panel;
    IBOutlet NSTextFieldCell *error_textfield;
    IBOutlet NSTextFieldCell *pwd_key_field;
    SqliteHelper *helper;
}

@property (nonatomic,retain) IBOutlet NSPanel *self_panel;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_key_field;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *error_textfield;

-(IBAction)onSearchEnd:(id)sender;

@end
