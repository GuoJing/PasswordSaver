//
//  AddKeyWindowController.m
//  PasswordSaver
//
//  Created by GuoJing on 12-11-28.
//
//

#import "AddKeyWindowController.h"

@implementation AddKeyWindowController

- (id)init {
    self = [super initWithWindowNibName:@"AddKeyWindow"];
    return self;
}

-(IBAction)showWindow:(id)sender{
    NSLog(@"show window");
    if(![[self window] isVisible]) {
        [[self window] orderFront:sender];
        [[self window] makeKeyAndOrderFront:sender];
        [[self window] initialFirstResponder];
    }
}

@end
