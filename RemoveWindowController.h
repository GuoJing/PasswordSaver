//
//  RemoveWindowController.h
//  PasswordSaver
//
//  Created by GuoJing on 12-12-1.
//
//

#import <Cocoa/Cocoa.h>
#import "SqliteHelper.h"

@interface RemoveWindowController : NSPanel {
    IBOutlet NSPanel *remove_panel;
    IBOutlet NSTextFieldCell *remove_field;
	IBOutlet NSButton *remove_button;
    SqliteHelper *helper;
}

@property (nonatomic,retain) IBOutlet NSPanel *remove_panel;
@property (nonatomic,retain) NSTextFieldCell *remove_field;
@property (nonatomic,retain) NSButton *remove_button;

-(IBAction)onRemoveButtonClicked:(id)sender;
@end
