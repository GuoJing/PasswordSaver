//
//  MainController.m
//  PasswordSaver
//
//  Created by GuoJing on 10-5-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainController.h"

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
@synthesize key_textfield;
@synthesize pwd_textfield;
@synthesize decs_textfield;
@synthesize done_button;
@synthesize loading_resc;
@synthesize error_textfield;
@synthesize mainwindow;
@synthesize keys;
@synthesize search_field;
@synthesize table_view;
@synthesize array_countroller;

-(id)init{
    [super init];
    keys = [[NSMutableArray alloc] init];
    helper = [[SqliteHelper alloc] init];
    return self;
}

-(IBAction)onTextInput:(id)sender{
	//get the password from db
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

}

-(IBAction)onAddButtonClicked:(id)sender{
	//if(!add_window)
	//	add_window = [[NSWindowController alloc] initWithWindowNibName:@"AddPanel"];
	//NSWindow *wnd = [add_window window];
	//if(![wnd isVisible])
	//	[wnd makeKeyAndOrderFront:sender];
	//else {
	//	[add_window showWindow: sender];
	//}
    [self emptyTextField:sender];
    NSLog(@"Add Botton Clicked");
	if(![add_panel isVisible])
    {
		[add_panel makeKeyAndOrderFront:sender];
    }
}

-(IBAction)onSearchWindowOpend:(id)sender{
    if(![search_panel isVisible])
    {
		[search_panel makeKeyAndOrderFront:sender];
        [self onSearchEnd:sender];
    }
}

-(IBAction)onAddPanelClosed:(id)sender{
    BOOL is_key_entered=[key_textfield.title isEqual:@""];
    BOOL is_pwd_entered=[pwd_textfield.title isEqual:@""];
    if(is_key_entered||is_pwd_entered)
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
    self.pwd_textfield.title = [self genRandStringLength:20];
}

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void  *userData){
    NSLog(@"call hot key %@", userData);
    NSWindowController *add_window = [[NSWindowController alloc] initWithWindowNibName:@"QuickWindow"];
    [add_window loadWindow];
    [[add_window window] makeMainWindow];
    [add_window showWindow:[add_window window]];
    [[add_window window] makeMainWindow];
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

-(IBAction)onKeyInputEnd:(id)sender{
    self.pwd_textfield.title = self.key_textfield.title;
}

@end
