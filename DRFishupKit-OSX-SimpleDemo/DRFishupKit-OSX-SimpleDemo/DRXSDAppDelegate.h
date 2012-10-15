//
//  DRXSDAppDelegate.h
//  DRFishupKit-OSX-SimpleDemo
//
//  Created by picasso on 14.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DRFishupKit/DRFishupKit.h>

@interface DRXSDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction)userInfo:(id)sender;

- (void)popularPhotosForPeriod:(NSString *)period;
- (IBAction)popularPhotosLastYear:(id)sender;
- (IBAction)popularPhotosLastMonth:(id)sender;
- (IBAction)popularPhotosLastWeek:(id)sender;
- (IBAction)myAlbums:(id)sender;
- (IBAction)uploadPtotos:(id)sender;

//@property (weak) IBOutlet NSTextView *fishupResponse;
@property (weak) IBOutlet NSProgressIndicator *networkActivity;
@property (weak) IBOutlet NSProgressIndicator *uploadProgress;
@property (unsafe_unretained) IBOutlet NSTextView *fishupResponse;


@end
