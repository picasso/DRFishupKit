//
//  DRUploadQueue.h
//  DRFishupKit
//
//  Created by picasso on 12.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRFishupKit.h"

@interface DRUploadFile : NSObject
@property (strong) NSString *filepath;
@property (strong) NSString *fileid;
@property (assign) NSInteger filesize;

@property (assign) double fileProgress;
@property (strong) NSString *uploadURL;
@property (assign) BOOL isPreparing;
@property (assign) BOOL isUploading;
@property (assign) BOOL isAdding;

- (id)initWithPath:(NSString *)path;
- (void) onCompleted:(DRDataBlock)data;

- (NSDictionary *) prepareUploadParams;
- (NSDictionary *) uploadParams;
- (NSDictionary *) addParams:(NSString *)galleryId;

- (void) updateUploadProgress:(double)update;
- (void) prepareCompleted:(id)data;
- (void) uploadCompleted:(id)data;
- (void) addCompleted:(id)data;


- (NSDictionary *) photodata;
- (NSString *) title;
- (void) setTitle:(NSString *)title;
- (NSString *) author;
- (void) setAuthor:(NSString *)author;
- (NSString *) desc;
- (void) setDesc:(NSString *)desc;
- (NSString *) tags;
- (void) setTags:(NSString *)tags;
- (NSString *) ticket;
- (void) setTicket:(NSString *)ticket;

@end

