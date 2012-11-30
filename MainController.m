//
//  MainController.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <DropboxOSX/DropboxOSX.h>
#import "MainController.h"
#import <stdlib.h>
#import <time.h>

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void  *userData);

@implementation MainController

@synthesize pwd_key_field;
@synthesize pwd_value_field;
@synthesize get_button;
@synthesize add_button;
@synthesize editable;
@synthesize add_window;
@synthesize add_panel;
@synthesize search_panel;
@synthesize loading_resc;
@synthesize error_textfield;
@synthesize mainwindow;
@synthesize keys;
@synthesize search_field;
@synthesize table_view;
@synthesize array_countroller;
@synthesize link_button;

-(id)init{
    [super init];
    keys = [[NSMutableArray alloc] init];
    helper = [[SqliteHelper alloc] init];
    return self;
}

-(IBAction)onTextInput:(id)sender{
    [helper connect];
    NSString *pwd = [helper checkPwd:pwd_key_field.title];
    [pwd retain];
    if(pwd && [pwd isEqualToString:@"N"])
    //if([pwd isEqualToString:@"N"])
    {
        pwd_value_field.title = @"No such a password";
    }
    else {
        pwd_value_field.title = pwd;
        [[NSPasteboard  generalPasteboard] declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner:nil];
        [[NSPasteboard  generalPasteboard] setString: pwd forType: NSStringPboardType];
    }
    [pwd release];
    [helper disconnect];
}

-(IBAction)onButtonClicked:(id)sender{
    if ([[DBSession sharedSession] isLinked]) {
        // The link button turns into an unlink button when you're linked
        [[DBSession sharedSession] unlinkAll];
        restClient = nil;
    } else {
        [[DBAuthHelperOSX sharedHelper] authenticate];
    }
}

-(IBAction)onSearchWindowOpend:(id)sender{
    if(![search_panel isVisible])
    {
		[search_panel makeKeyAndOrderFront:sender];
        [self onSearchEnd:sender];
    }
}

-(IBAction)onSearchEnd:(id)sender{
    [helper connect];
    NSString *searchtext = search_field.title;
    NSMutableArray *array = [helper getValues:searchtext];
    [array_countroller removeObjects:keys];
    [keys removeAllObjects];
    for(KeyModel *keyModel in array)
    {
        [array_countroller addObject:keyModel];
    }
    [helper disconnect];
}

-(IBAction)onSearchWindowOrderFront:(id)sender{
    
}

-(void)awakeFromNib{
    EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    EventTypeSpec eventType;
    
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType,self,NULL);
    myHotKeyID.signature='mhk1';
    myHotKeyID.id=1;
    NSLog(@"%d", cmdKey);
    NSLog(@"%d", optionKey);
    RegisterEventHotKey(49, cmdKey+optionKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
    NSLog(@"awake");
}

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void  *userData){
    NSLog(@"call hot key %@", userData);
    NSWindowController *add_window = [[NSWindowController alloc] initWithWindowNibName:@"QuickWindow"];
    [add_window loadWindow];
    if (![[add_window window] isVisible]){
        [[add_window window] makeMainWindow];
        [add_window showWindow:[add_window window]];
        [[add_window window] makeMainWindow];
    }
    return noErr;
}

-(void)dealloc{
    [self.array_countroller release];
    [super dealloc];
}

-(NSString *) genRandStringLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}


-(IBAction)openAddKeyWindow:(id)sender{
    NSWindowController *key_window = [[NSWindowController alloc] initWithWindowNibName:@"AddKeyWindow"];
    if(![[key_window window] isVisible]) {
        [key_window showWindow:sender];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *root = kDBRootAppFolder; // Should be either kDBRootDropbox or kDBRootAppFolder
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];
    
    NSDictionary *plist = [[NSBundle mainBundle] infoDictionary];
    NSString *actualScheme = [[[[plist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    NSString *desiredScheme = [NSString stringWithFormat:@"db-%@", appKey];
    NSString *alertText = nil;
    if ([appKey isEqual:@"APP_KEY"] || [appSecret isEqual:@"APP_SECRET"] || root == nil) {
        alertText = @"Fill in appKey, appSecret, and root in AppDelegate.m to use this app";
    } else if (![actualScheme isEqual:desiredScheme]) {
        alertText = [NSString stringWithFormat:@"Set the url scheme to %@ for the OAuth authorize page to work correctly", desiredScheme];
    }
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
    
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:)
          forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    if ([[DBSession sharedSession] isLinked]) {
        NSLog(@"linked");
        self.link_button.title = @"Unlink";
    } else {
        self.link_button.title = @"Link";
    }
}

#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", nil];
    NSMutableArray* newPhotoPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newPhotoPaths addObject:child.path];
        }
    }
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", error);
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadThumbnailFailedWithError: %@", error);
}

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
    }
}

@end
