//
//  DRXDAppDelegate.m
//  DRFishupKit-OSX-Demo
//
//  Created by picasso on 16.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import <DRFishupKit/DRFishupKit.h>
#import "DRXDAppDelegate.h"
#import "DRXDImageCell.h"

#define kMinimumOutlineWidth    300

#define kNumberOfShakes         8
#define kDurationOfShake        0.5f
#define kVigourOfShake          0.05f

#define kMyFishupKey            @"Мой Фишап"
#define kSonyAlpha900           @"1194"     // 1194 - id of camera Sony DSLR-900 on Fishup

@interface DRXDAppDelegate ()

// data for NSOutline ----------------------------------
@property (strong) NSMutableDictionary *outlineData;
@property (strong) NSDictionary *publicOutline;
@property (strong) NSArray *myOutline;

// data for IKImageBrowserView -------------------------
@property (strong) NSArray *photos;
@property (copy) NSString *photoKey;
@property (copy) NSString *titleKey;
@property (copy) NSString *authorKey;
@property (copy) NSString *idKey;
@property (copy) NSString *selectedGallery;

// Animations & Effects  -------------------------------
@property (strong) NSView *blackoutView;
@property (assign) BOOL insideBlackout;
@property (assign) BOOL waitingBlackout;
@property (assign) BOOL forceBlackout;

 // Fishup API instance --------------------------------
@property (strong) DRFishupEngine *engine;

@end

@implementation DRXDAppDelegate
@synthesize outlineData = _outlineData, outline = _outline, publicOutline = _publicOutline, myOutline = _myOutline;
@synthesize photos = _photos, photoKey = _photoKey, titleKey = _titleKey, authorKey = _authorKey, idKey = _idKey;
@synthesize blackoutView = _blackoutView, insideBlackout = _insideBlackout, waitingBlackout = _waitingBlackout, forceBlackout = _forceBlackout;
@synthesize engine = _engine;

@synthesize browser = _browser, placeholder = _placeholder, loginPanel = _loginPanel, selectedGallery = _selectedGallery;
@synthesize networkActivity = _networkActivity, uploadProgress = _uploadProgress, loginField = _loginField, passwordField = _passwordField;


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	return YES;
}

- (void) awakeFromNib
{
    self.publicOutline = @{
    
    @"Фишап" :    @[
    @{ @"name" :@"Популярные", @"selector" :@"popular"},
    @{ @"name" :@"Интересные", @"selector" :@"interesting"},
    @{ @"name" :@"Обсуждаемые", @"selector" :@"commented"},
    @{ @"name" :@"", @"selector" : @""} // empty selector
    ],
    
    kMyFishupKey : @[
    @{ @"name" :@"Войти в аккаунт", @"selector" :@"mylogin"},
    @{ @"name" :@"", @"selector" : @""}
    ],
    
    @"Избранное" : @[
    @{ @"name" :@"Новые снимки за последний день", @"selector" :@"newday"},
    @{ @"name" :@"Снимки по тэгу Iceland", @"selector" :@"iceland"},
    @{ @"name" :@"Снимки содержащие Sunrise", @"selector" :@"sunrise"},
    @{ @"name" :@"Снимки снятые Sony Alpha-900", @"selector" :@"sonyalpha"},
    @{ @"name" :@"", @"selector" : @""}
    ]
    };

    self.myOutline = @[
    @{ @"name" :@"Мои альбомы", @"selector" :@"myalbums"},
    @{ @"name" :@"Мои снимки", @"selector" :@"myphotos"},
    @{ @"name" :@"Круг общения", @"selector" :@"mycircle"},
    @{ @"name" :@"", @"selector" : @""},
    @{ @"name" :@"Загрузить снимки в альбом", @"selector" :@"myupload"},
    @{ @"name" :@"", @"selector" : @""},
    @{ @"name" :@"Выйти из аккаунта", @"selector" :@"mylogout"}
    ];

    self.outlineData = [self.publicOutline mutableCopy];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[self.outline outlineTableColumn] setWidth:kMinimumOutlineWidth];
    [self updateOutline];
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:[self.browser frame]];
    
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutohidesScrollers:YES];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [scrollView setDocumentView:self.browser];
    
    [self.placeholder addSubview:scrollView];

    // make sure our added browser is placed and resizes correctly
    [scrollView setFrame:[self.placeholder frame]];
    [scrollView setFrameOrigin:NSZeroPoint];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [self.browser setZoomValue:0.5f];
    
    DRFishupEngine *engine = [[DRFishupEngine alloc] init];
    self.engine = engine;
    
    [engine onNetworked:^{
        if(self.engine.isNetworkActive) {
            [self.networkActivity startAnimation:self];
        } else {
            [self.networkActivity stopAnimation:self];
        }
    }];
}

- (void) updateOutline
{
    [self.outline reloadData];
    
    // Expand all the root items; disable the expansion animation that normally happens
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.0];
    [self.outline expandItem:nil expandChildren:YES];
    [NSAnimationContext endGrouping];
}

#pragma mark - Login Panel methods

- (void)mylogin
{
    [self.outline deselectAll:self];
    [self instantBlackout];
    [NSApp beginSheet:self.loginPanel modalForWindow:self.window  modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)mylogout
{
    [self.engine logout];
    [self.outlineData setObject:[self.publicOutline objectForKey:kMyFishupKey] forKey:kMyFishupKey];
    [self updateOutline];
    [self updateWith:[NSArray array]];
}

- (IBAction) loginCancel:(id)sender
{
    [NSApp endSheet:self.loginPanel];
    [self.loginPanel orderOut:self];
    [self.outline deselectAll:self];
    [self stopBlackout];
}

- (IBAction) loginOk:(id)sender
{
    NSString *login = [self.loginField stringValue];
    NSString *pass = [self.passwordField stringValue];
    
    if([self.engine login:login password:pass andWait:YES]) {
        [self.outlineData setObject:self.myOutline forKey:kMyFishupKey];
        [self updateOutline];
        [self loginCancel:self];
    }
    else
        [self wasWrong];
}

#pragma mark - Fishup Communications

- (void) updateWith:(NSArray *)data photo:(NSString *)pkey title:(NSString *)tkey authorKey:(NSString *)akey oid:(NSString *)ikey
{
    self.photoKey = (pkey == nil) ? @"photo.preview.url" : pkey;
    self.titleKey = (tkey == nil) ? @"title" : tkey;
    self.authorKey = (akey == nil) ? @"author" : akey;
    self.idKey = (ikey == nil) ? nil : ikey;
    
    self.photos = data;
    [self.browser reloadData];
    [self.browser scrollIndexToVisible:0];
}

- (void) updateWith:(NSArray *)data
{
    [self updateWith:data photo:nil title:nil authorKey:nil oid:nil];
}

// Favorities

- (void) iceland
{
    [self startBlackout];
    [self.engine sendAPI:@"search.tags" withTerm:@"iceland" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

- (void) sunrise
{
    [self startBlackout];
    [self.engine sendAPI:@"search.text" withTerm:@"sunrise" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

- (void) newday
{
    [self startBlackout];
    [self.engine sendAPI:@"new.day" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

- (void) sonyalpha  
{
    [self startBlackout];
    [self.engine sendAPI:@"search.camera" withTerm:kSonyAlpha900 onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

// Fishup public

- (void) popular
{
    [self startBlackout];
    [self.engine sendAPI:@"top.year" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

- (void) commented
{
    [self startBlackout];
    [self.engine sendAPI:@"commented.year" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

- (void) interesting
{
    [self startBlackout];
    [self.engine sendAPI:@"interesting" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data];
    }];
}

// My Fishup

- (void) mycircle
{
    [self startBlackout];
    [self.engine sendAPI:@"my.circle" withExtras:@"small_photo_id" onCompletion:^(NSArray *data) {
                
        [self stopBlackout];
        [self updateWith:data photo:@"photo.smallphoto.url" title:@"first_name" authorKey:@"base_hostname" oid:nil];
    }];
}

- (void) myalbums
{
    [self startBlackout];
    [self.engine sendAPI:@"my.albums" withExtras:@"preview_file" onCompletion:^(NSArray *data) {
        
        [self stopBlackout];
        [self updateWith:data photo:nil title:@"title" authorKey:@"" oid:@"id"];
    }];
}

- (void) myphotos
{
    [self startBlackout];
    [self.engine sendAPI:@"my.photos" withExtras:@"preview_file" onCompletion:^(NSArray *data) {
    
        [self stopBlackout];
        [self updateWith:data];
    }];
}

#pragma mark - Upload Files to Fishup

- (void) myupload
{
    [self instantBlackout];
    [self.engine sendAPI:@"my.albums" onCompletion:^(NSArray *data) {
        
        [self selectGallery:data];
    }];

}

- (void) selectGallery:(NSArray *)data
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Select album for upload files:"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSPopUpButton *albums = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 300, 24) pullsDown:NO];

    for(NSDictionary *item in data) {
        
        [albums addItemWithTitle:[item objectForKey:@"title"]];
        [[albums lastItem] setTag:[[item objectForKey:@"id"] integerValue]];
    }

    [alert setAccessoryView:albums];

    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        self.selectedGallery = [NSString stringWithFormat:@"%ld", [[albums selectedItem] tag]];
        [self openFiles:self];
    }
    
    return;
}

- (void) uploadFiles:(NSArray *)urls
{
    [self.engine addUploads:urls];
    
    for(NSURL *url in urls) {
        
        DRUploadFile *file = [self.engine uploadForPath:[url path]];
        file.author = NSUserName();
        file.tags = [NSString stringWithFormat:@"tag1, tag2, tag3"];
    }
    
    [self.engine onProgress:^(double progress) {
        
        [self.uploadProgress setDoubleValue:progress];
    }];
    
    [self.uploadProgress setDoubleValue:0.0f];
    [self.uploadProgress setHidden:NO];

    [self.engine uploadToGallery:self.selectedGallery onCompletion:^(NSArray *list) {

        NSLog(@"upload of %ld of %ld files completed\n", [list count], [urls count]);
        [self.engine cleanUploads];
        [self.uploadProgress setHidden:YES];

        self.engine.forceReload = YES; // we force the request reload as we just have added some images to album
        [self.engine sendAPI:@"my.photosOfAlbum" withTerm:self.selectedGallery onCompletion:^(NSArray *data) {
            
            [self stopBlackout];
            [self.outline deselectAll:self];
            [self updateWith:data];
        }];
    }];
}

- (void) openFiles:(id)sender {
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    [panel setAllowedFileTypes:[self.engine onlyJpeg]];
    [panel setMessage:@"Choose one or more jpeg-files to upload..."];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            
            [self uploadFiles:[panel URLs]];
        }
    }];
}


#pragma mark - NSOutlineViewDelegate Protocol methods

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return [item isKindOfClass:[NSArray class]] ? YES : NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return [item isKindOfClass:[NSArray class]] ? NO : ([[item objectForKey:@"name"] length] == 0 ? NO : YES);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *outlineView = notification.object;
    
    if([outlineView selectedRow] != -1) {
        
        NSString *selector = [[outlineView itemAtRow:[outlineView selectedRow]] objectForKey:@"selector"];
        SEL selectedItem = NSSelectorFromString(selector);
        if([self respondsToSelector:selectedItem]) {
            
// special pragmas to fix warning: performSelector may cause a leak
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selectedItem];
#pragma clang diagnostic pop
            
        } else
            NSLog(@"%@ can’t be performed\n", selector);
    }
}

#pragma mark - NSOutlineViewDataSource Protocol methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return (item == nil) ? [self.outlineData count] : ([item isKindOfClass:[NSArray class]] ? [item count] : 0);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [item isKindOfClass:[NSArray class]] ? YES : NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(item == nil) {
        int i = 0;
        for(NSString *key in self.outlineData)
            if(index == i++) return [self.outlineData objectForKey:key];
        return nil;
        
    } else
        return [item objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if([item isKindOfClass:[NSArray class]]) {
        
        for(NSString *key in self.outlineData)
            if(item == [self.outlineData objectForKey:key]) return [key uppercaseString];
        return nil;
    }
 
   if([item isKindOfClass:[NSDictionary class]]) {
        return [item objectForKey:@"name"];
    }
    return nil;
}

#pragma mark - NSSplitViewDelegate Protocol methods

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return proposedMaximumPosition - kMinimumOutlineWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMinimumPosition + kMinimumOutlineWidth;
}

#pragma mark - IKImageBrowserDataSource Protocol methods

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
    return [self.photos count];
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
    DRXDImageCell *cell = [[DRXDImageCell alloc] init];
    NSDictionary *item = [self.photos objectAtIndex:index];
    NSString *urlpath = [item valueForKeyPath:self.photoKey];
    
    cell.title = [item objectForKey:self.titleKey];
    cell.subtitle = [item objectForKey:self.authorKey];
    cell.oid = [[item objectForKey:self.idKey] stringValue];
    
    if([urlpath length]) {
        cell.url = [NSURL URLWithString:urlpath];
        
        [self.engine imageAtURL:cell.url
         
                   onCompletion:^(NSImage *fetchedImage, NSURL *url, BOOL isInCache) {
                       
                       if([[cell.url absoluteString] isEqualToString:[url absoluteString]]) {
                           
                           if(isInCache) {
                               cell.image = fetchedImage;
                           } else {
                               cell.image = fetchedImage;
                               [self.browser setNeedsDisplay:YES];
                           }
                       }
        }];
    }
    return cell;
}

#pragma mark - IKImageBrowserDelegate Protocol methods

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
    NSIndexSet *indexes = [aBrowser selectionIndexes];
    if([indexes count] != 0) {
        
        // Do something with selection!
    }
}

- (void) imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    DRXDImageCell *cell = [[aBrowser cellForItemAtIndex:index] representedItem];
    
    if(cell.oid != nil) { // double click at gallery

        [self startBlackout];
        [self.engine sendAPI:@"my.photosOfAlbum" withTerm:cell.oid onCompletion:^(NSArray *data) {
            
            [self stopBlackout];
            [self.outline deselectAll:self];
            [self updateWith:data];
        }];
    }
}

- (IBAction) zoomDidChange:(id)sender
{
    [self.browser setZoomValue:[sender floatValue]];
    [self.browser setNeedsDisplay:YES];
}


#pragma mark - Effects for Network Activity

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	int index;
	for (index = 0; index < kNumberOfShakes; ++index)
	{
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * kVigourOfShake, NSMinY(frame));
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * kVigourOfShake, NSMinY(frame));
	}
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = kDurationOfShake;
    return shakeAnimation;
}

- (void) wasWrong
{
	[self.loginPanel setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:[self.loginPanel frame]] forKey:@"frameOrigin"]];
	[[self.loginPanel animator] setFrameOrigin:[self.loginPanel frame].origin];
}

- (void) instantBlackout
{
    if(!self.insideBlackout) {
        self.forceBlackout = YES;
        [self makeBlackout];
    }
}

- (void) startBlackout
{
    if(!self.insideBlackout) {
        self.waitingBlackout = YES;
        [self performSelector:@selector(makeBlackout) withObject:nil afterDelay:0.5f]; // wait for 0.5 sec to avoid flickering
    }
}

- (void) makeBlackout
{
    if(!self.insideBlackout && (self.waitingBlackout || self.forceBlackout)) {
        
        self.insideBlackout = YES;
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [[self.placeholder layer] addAnimation:animation forKey:@"layerAnimation"];
        
        self.blackoutView = [[NSView alloc] initWithFrame:[self.placeholder bounds]];
        [self.placeholder addSubview:self.blackoutView];
        
        CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [exposureFilter setDefaults];
        [exposureFilter setValue:[NSNumber numberWithDouble:-1.25] forKey:@"inputEV"];
        CIFilter *saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
        [saturationFilter setDefaults];
        [saturationFilter setValue:[NSNumber numberWithDouble:0.35] forKey:@"inputSaturation"];
        CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setDefaults];
        [blurFilter setValue:[NSNumber numberWithDouble:2.0] forKey:@"inputRadius"];
        
        [[self.blackoutView layer] setBackgroundFilters:[NSArray arrayWithObjects:exposureFilter, saturationFilter, blurFilter, nil]];
    }
    self.waitingBlackout = self.forceBlackout = NO;
}

- (void) stopBlackout
{
    if(self.insideBlackout) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [[self.placeholder layer] addAnimation:animation forKey:@"layerAnimation"];
        
        [self.blackoutView removeFromSuperview];
        self.blackoutView = nil;
    }
    
    self.waitingBlackout = self.forceBlackout = self.insideBlackout = NO;
}

@end
