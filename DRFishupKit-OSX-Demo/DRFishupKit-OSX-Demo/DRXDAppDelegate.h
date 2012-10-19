//
//  DRXDAppDelegate.h
//  DRFishupKit-OSX-Demo
//
//  Created by picasso on 16.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface DRXDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSWindow *loginPanel;
@property (weak) IBOutlet NSOutlineView *outline;
@property (strong) IBOutlet IKImageBrowserView *browser;
@property (weak) IBOutlet NSView *placeholder;
@property (weak) IBOutlet NSProgressIndicator *uploadProgress;
@property (weak) IBOutlet NSProgressIndicator *networkActivity;
@property (weak) IBOutlet NSTextField *loginField;
@property (weak) IBOutlet NSTextField *passwordField;

- (IBAction) zoomDidChange:(id)sender;
- (IBAction) loginOk:(id)sender;
- (IBAction) loginCancel:(id)sender;

@end
