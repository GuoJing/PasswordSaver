//
//  MainController.h
//  PasswordSaver
//
//  Created by GuoJing on 10-5-1.
//  Copyright 2010 GuoJingMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <DropboxOSX/DropboxOSX.h>
#import <WebKit/WebKit.h>
#import "SqliteHelper.h"
#import "QuickWindowController.h"
#import "KeyModel.h"

@interface MainController : NSWindow {
	IBOutlet NSTextFieldCell *pwd_key_field;
	IBOutlet NSTextFieldCell *pwd_value_field;
	IBOutlet NSButton *get_button;
	IBOutlet NSButton *add_button;
    IBOutlet NSButton *link_button;
	IBOutlet NSNumber *editable;
	IBOutlet NSWindowController *add_window;
	IBOutlet NSPanel *add_panel;
    IBOutlet NSPanel *search_panel;
    IBOutlet NSProgressIndicator *loading_resc;
    IBOutlet NSWindow *mainwindow;
    IBOutlet NSMutableArray *keys;
    IBOutlet NSSearchFieldCell *search_field;
    IBOutlet NSTableView *table_view;
    IBOutlet NSArrayController *array_countroller;
    DBRestClient *restClient;
    SqliteHelper *helper;
    
}

@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_key_field;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *pwd_value_field;
@property (nonatomic,retain) IBOutlet NSButton *get_button;
@property (nonatomic,retain) IBOutlet NSButton *add_button;
@property (nonatomic,retain) IBOutlet NSWindowController *add_window;
@property (nonatomic,retain) IBOutlet NSPanel *add_panel;
@property (nonatomic,retain) IBOutlet NSPanel *search_panel;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *error_textfield;
@property (nonatomic,retain) IBOutlet NSSearchFieldCell *search_field;
@property (nonatomic,retain) IBOutlet NSButton *link_button;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *loading_resc;
@property (readonly) NSNumber *editable;
@property (nonatomic,retain) IBOutlet NSWindow *mainwindow;
@property (nonatomic,retain) IBOutlet NSMutableArray *keys;
@property (nonatomic,retain) IBOutlet NSTableView *table_view;
@property (nonatomic,retain) IBOutlet NSArrayController *array_countroller;

@property (nonatomic, retain) NSArray *filePaths;
@property (nonatomic, retain) NSArray *fileRevs;
@property (nonatomic, retain) NSString *currentFilePath;
@property (nonatomic, retain) NSString *fileHash;

-(NSString *) genRandStringLength: (int) len;

-(IBAction)onTextInput:(id)sender;
-(IBAction)onButtonClicked:(id)sender;
-(IBAction)onSearchEnd:(id)sender;
-(IBAction)onSearchWindowOrderFront:(id)sender;
-(IBAction)onSearchWindowOpend:(id)sender;
-(IBAction)openAddKeyWindow:(id)sender;

- (DBRestClient *)restClient;
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata;
@end
