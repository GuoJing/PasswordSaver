//
//  AddWindowController.h
//  PasswordSaver
//
//  Created by GuoJing on 12-11-28.
//
//

#import <Cocoa/Cocoa.h>
#import "SqliteHelper.h"

@interface AddWindowController : NSWindow {
    IBOutlet NSTextFieldCell *key_textfield;
    IBOutlet NSTextFieldCell *pwd_textfield;
    IBOutlet NSTextFieldCell *error_textfield;
    IBOutlet NSTextFieldCell *decs_textfield;
    IBOutlet NSPanel *add_panel;
    IBOutlet NSButton *done_button;
    IBOutlet NSProgressIndicator *loading_resc;
    SqliteHelper *helper;
}

@property (nonatomic,retain) IBOutlet NSTextFieldCell *key_textfield;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_textfield;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *error_textfield;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *decs_textfield;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *loading_resc;
@property (nonatomic,retain) IBOutlet NSButton *done_button;
@property (nonatomic,retain) IBOutlet NSPanel *add_panel;

-(IBAction)onAddButtonClicked:(id)sender;
-(IBAction)emptyTextField:(id)sender;

@end
