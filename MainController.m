//
//  MainController.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-1.
//  Copyright 2010 GuoJingMe. All rights reserved.
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

@synthesize fileHash;
@synthesize filePaths;
@synthesize fileRevs;
@synthesize currentFilePath;

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

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    self.fileHash = metadata.hash;
    NSArray* validExtensions = [NSArray arrayWithObjects:@"sql", @"pwd", @"", nil];
    NSMutableArray* newFilePaths = [NSMutableArray new];
    NSMutableArray* newFileRevs = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newFilePaths addObject:child.path];
            [newFileRevs addObject:child.rev];
        }
    }
    self.filePaths = newFilePaths;
    self.fileRevs = newFileRevs;
    [self uploadFromDropboxFile];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    [self loadFromDropboxFile];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *root = kDBRootAppFolder; // Should be either kDBRootDropbox or kDBRootAppFolder
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
    
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:)
          forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    if ([[DBSession sharedSession] isLinked]) {
        NSString *fileRoot = nil;
        NSLog(@"linked");
        self.link_button.title = @"Unlink";
        fileRoot = @"/";
        [self.restClient loadMetadata:fileRoot withHash:self.fileHash];
    } else {
        //NSString *msg = @"Please sync to dropbox";
        //NSAlert *alert = [NSAlert alertWithMessageText:nil defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:msg];
        //[alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
        self.link_button.title = @"Link";
    }
}

- (void)uploadFromDropboxFile {
    NSString *path = [self filePath];
    NSString *filename = kFileName;
    NSString *destDir = @"/";
    if ([self.filePaths count] == 0) {
        NSLog(@"upload new file");
        [[self restClient] uploadFile:filename toPath:destDir
                        withParentRev:nil fromPath:path];
    } else {
        NSString* fileRev;
        fileRev = [self.fileRevs objectAtIndex:0];
        NSLog(@"cover the file");
        [[self restClient] uploadFile:filename toPath:destDir
                        withParentRev:fileRev fromPath:path];
    }
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@, rev: %@ ", metadata.path, metadata.rev);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)loadFromDropboxFile {
    if ([self.filePaths count] == 0) {
        NSLog(@"WARN: No file in app folder");
    } else {
        NSString* filePath;
        filePath = [self.filePaths objectAtIndex:0];
        if ([filePath isEqual:self.currentFilePath]) {
            NSLog(@"find file");
            return;
        }
        self.currentFilePath = filePath;
        NSLog(@"current file path %@", filePath);
        [self.restClient loadFile:self.currentFilePath intoPath:[self filePath]];
    }
}

- (NSString*)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:kFileName];
    return path;
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = (id)self;
    }
    return restClient;
}

#pragma mark DBRestClientDelegate

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
    }
}

@end
