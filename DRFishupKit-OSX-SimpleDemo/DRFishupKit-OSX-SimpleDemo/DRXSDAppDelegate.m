//
//  DRXSDAppDelegate.m
//  DRFishupKit-OSX-SimpleDemo
//
//  Created by picasso on 14.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#define kFishupMyLogin      @"ifishup"
#define kFishupMyPassword   @"ifishupkit"
#define kFishupMyGalleryID  @"1476381"
#define kUserID             @"1100651"


#import "DRXSDAppDelegate.h"

@interface DRXSDAppDelegate()
@property (strong) DRFishupEngine *engine;
@end

@implementation DRXSDAppDelegate
@synthesize engine = _engine, fishupResponse = _fishupResponse, networkActivity = _networkActivity;
@synthesize uploadProgress = _uploadProgress; // !!Не забудьте установить значения прогресс-индикатор Min = 0 и Max = 1

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // truncate long lines in TextView
    NSMutableParagraphStyle *truncateStyle = [[NSMutableParagraphStyle alloc] init];
    [truncateStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.fishupResponse setDefaultParagraphStyle:truncateStyle];
    
self.engine = [[DRFishupEngine alloc] init];

[self.engine onError:^(NSError *error) {
  
    if(error.code == 16000) { // Данный метод требует дополнительных параметров
        [[NSAlert alertWithError:error] runModal];
    }
    else
        NSLog(@"Произошла ошибка:%@", error);
}];

[self.engine onNetworked:^{
    
    if(self.engine.isNetworkActive)
        [self.networkActivity startAnimation:self];
    else
        [self.networkActivity stopAnimation:self];
}];
    
}

- (void) clearText
{
    [self.fishupResponse setString:@""];
}

// Пример 1. Получение информации о пользователе --------------------------
// 
- (IBAction)userInfo:(id)sender
{
    [self clearText];
    [self.engine sendAPI:@"accounts.user.getPublicData"
              withParams:[NSDictionary dictionaryWithObject:kUserID forKey:@"id"]
            onCompletion:^(NSDictionary *data) {
        
        [self.fishupResponse setString:[data description]];
    }];
 }

// Пример 2. Получение списка популярных фотографий за последний год -------
//
- (void)popularPhotosForPeriod:(NSString *)period
{
    [self clearText];
    [self.engine sendAPI:period onCompletion:^(NSArray *data) {
        
        [self.fishupResponse setString:[data description]];
    }];
}

- (IBAction)popularPhotosLastYear:(id)sender
{
    [self popularPhotosForPeriod:@"top.year"];
}

- (IBAction)popularPhotosLastMonth:(id)sender
{
    [self popularPhotosForPeriod:@"top.month"];
}

- (IBAction)popularPhotosLastWeek:(id)sender
{
    [self popularPhotosForPeriod:@"top.week"];
}


// Пример 3. Получение списка альбомов для своего аккаунта ----------------
//
- (IBAction)myAlbums:(id)sender
{
    [self clearText];
    BOOL isLoginOk = [self.engine login:kFishupMyLogin password:kFishupMyPassword andWait:YES];
    
    if(isLoginOk) {
        [self.engine sendAPI:@"my.albums" onCompletion:^(NSArray *data) {
            
            NSArray *squareURLs = [data valueForKeyPath:@"photo.square.url"];
            [self.fishupResponse setString:[squareURLs description]];
        }];
    }
}

// Пример 4. Загрузка фотографий в новый альбом --------------------------
//
- (IBAction)uploadPtotos:(id)sender
{
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


- (void) uploadFiles:(NSArray *)urls
{
    [self clearText];
    [self.engine addUploads:urls];
    
    int i =0;
    for(NSURL *url in urls) {
        
        DRUploadFile *file = [self.engine uploadForPath:[url path]];
        
        file.title = [NSString stringWithFormat:@"Myfile#%d", (i++ +1)];
        file.author = @"Dmitry Rudakov";
        file.desc = @"Apple has been busy this year, updating Mac OS X to version 10.8";
        file.tags = [NSString stringWithFormat:@"tag%d, tag%d, tag%d", i+1, i+2, i+3];
    }
    
    [self.engine onProgress:^(double progress) {
        
        [self.uploadProgress setDoubleValue:progress];
    }];
    
    [self.engine uploadToGallery:kFishupMyGalleryID onCompletion:^(NSArray *list) {
        
        NSLog(@"upload of %ld of %ld files completed\n", [list count], [urls count]);
        for(DRUploadFile *file in list)
            NSLog(@"%@ (id=%@)\n", file.title, file.fileid);
    }];
}

@end
