//
//  MainController.h
//  PasswordSaver
//
//  Created by GuoJing on 10-5-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "SqliteHelper.h"
#import "QuickWindowController.h"
#import "KeyModel.h"

@interface MainController : NSWindow {
	IBOutlet NSTextFieldCell *pwd_key_field;
	IBOutlet NSTextFieldCell *pwd_value_field;
	IBOutlet NSButton *get_button;
	IBOutlet NSButton *add_button;
	IBOutlet NSNumber *editable;
	IBOutlet NSWindowController *add_window;
	IBOutlet NSPanel *add_panel;
    IBOutlet NSPanel *search_panel;
    IBOutlet NSTextFieldCell *key_textfield;
    IBOutlet NSTextFieldCell *pwd_textfield;
    IBOutlet NSTextFieldCell *error_textfield;
    IBOutlet NSTextFieldCell *decs_textfield;
    IBOutlet NSButton *done_button;
    IBOutlet NSProgressIndicator *loading_resc;
    IBOutlet NSWindow *mainwindow;
    IBOutlet NSMutableArray *keys;
    IBOutlet NSSearchFieldCell *search_field;
    IBOutlet NSTableView *table_view;
    IBOutlet NSArrayController *array_countroller;
    SqliteHelper *helper;
    
}

@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_key_field;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_value_field;
@property (nonatomic,retain) IBOutlet NSButton *get_button;
@property (nonatomic,retain) IBOutlet NSButton *add_button;
@property (nonatomic,retain) IBOutlet NSWindowController *add_window;
@property (nonatomic,retain) IBOutlet NSPanel *add_panel;
@property (nonatomic,retain) IBOutlet NSPanel *search_panel;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *key_textfield;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_textfield;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *decs_textfield;
@property (nonatomic,retain) IBOutlet NSButton *done_button;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *error_textfield;
@property (nonatomic,retain) IBOutlet NSSearchFieldCell *search_field;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *loading_resc;
@property (readonly) NSNumber *editable;
@property (nonatomic,retain) IBOutlet NSWindow *mainwindow;
@property (nonatomic,retain) IBOutlet NSMutableArray *keys;
@property (nonatomic,retain) IBOutlet NSTableView *table_view;
@property (nonatomic,retain) IBOutlet NSArrayController *array_countroller;
-(NSString *) genRandStringLength: (int) len;

-(IBAction)onTextInput:(id)sender;
-(IBAction)onButtonClicked:(id)sender;
-(IBAction)onAddButtonClicked:(id)sender;
-(IBAction)onAddPanelClosed:(id)sender;
-(IBAction)emptyTextField:(id)sender;
-(IBAction)onSearchEnd:(id)sender;
-(IBAction)onSearchWindowOrderFront:(id)sender;
-(IBAction)onSearchWindowOpend:(id)sender;
-(IBAction)onKeyInputEnd:(id)sender;
-(IBAction)openAddKeyWindow:(id)sender;
@end
