//
//  DRUploadFile.m
//  DRFishupKit
//
//  Created by picasso on 12.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRUploadFile.h"

@interface DRUploadFile () {

    struct {
        double prepare;
        double upload;
        double add;
    } progress;
}


@property (strong) NSMutableDictionary *photo;
@property (copy) DRDataBlock completedBlock;
@end

@implementation DRUploadFile
@synthesize photo = _photo, completedBlock = _completedBlock, isPreparing = _isPreparing, isUploading = _isUploading, isAdding = _isAdding;
@synthesize filepath = _filepath, filesize = _filesize, fileid = _fileid, uploadURL = _uploadURL, fileProgress = _fileProgress;

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        
        self.filepath = path;
        
        self.photo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      [[path lastPathComponent] stringByDeletingPathExtension], @"title",
                      @"", @"author",
                      @"", @"description",
                      @"", @"tags",
                      [NSNull null], @"original_file",
                      nil];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            self.filesize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            
            // setup progress weights depending on file size
            progress.prepare = 5.0/100.0;
            progress.upload = 60.0/100.0;
            progress.add = 35.0/100.0;
            self.fileProgress = 0;
            
        } else
            self.filesize = 0;
        
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"DRUploadFile (%.0f%% - %@): title:%@ (%@)\npath=%@ [%ld kB]\n{%@}",
            self.fileProgress * 100,
            self.isPreparing ? @"preparing" :(self.isUploading ? @"uploading" :(self.isAdding ? @"adding" : @"still")),
            self.title,
            self.fileid,
            self.filepath,
            self.filesize/1024,
            self.photo];
}

#pragma mark - Upload params methods

- (NSDictionary *) prepareUploadParams
{
    self.isPreparing = YES;
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self.filepath lastPathComponent], @"file_name",
            [NSNumber numberWithInteger:self.filesize], @"file_size",
            @"1", @"chunk_quantity",
            nil];
}

- (NSDictionary *) uploadParams
{
    self.isUploading = YES;
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.ticket, @"ticket",
            @"1", @"chunk_num",
            nil];
}

- (NSDictionary *) addParams:(NSString *)galleryId
{
    self.isAdding = YES;
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.photo, @"data",
            galleryId, @"gallery_id",
            nil];
}

#pragma mark - Upload completed methods

- (void) onCompleted:(DRDataBlock)data
{
    self.completedBlock = data;
}

- (void) updateUploadProgress:(double)update
{
    self.fileProgress = progress.prepare + update*progress.upload;
}

- (void) prepareCompleted:(id)data
{
    self.isPreparing = NO;
    self.ticket = [data objectForKey:@"ticket"];
    self.uploadURL = [data objectForKey:@"upload_url"];
    self.fileProgress = progress.prepare;
}

- (void) uploadCompleted:(id)data
{
    self.isUploading = NO;
    self.fileProgress = progress.prepare + progress.upload;
}

- (void) addCompleted:(id)data
{
    self.isAdding = NO;
    self.fileid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
    self.fileProgress = 1.0;
}

#pragma mark - Convenience methods for photodata access

- (NSDictionary *) photodata
{
    return self.photo;
}

- (NSString *) title
{
    return [self.photo valueForKey:@"title"];
}

- (void) setTitle:(NSString *)title
{
    [self.photo setValue:title forKey:@"title"];
}

- (NSString *) author
{
    return [self.photo valueForKey:@"author"];
}

- (void) setAuthor:(NSString *)author
{
    [self.photo setValue:author forKey:@"author"];
}

- (NSString *) desc
{
    return [self.photo valueForKey:@"description"];
}

- (void) setDesc:(NSString *)desc
{
    [self.photo setValue:desc forKey:@"description"];
}

- (NSString *) tags
{
    return [self.photo valueForKey:@"tags"];
}

- (void) setTags:(NSString *)tags
{
    [self.photo setValue:tags forKey:@"tags"];
}

- (NSString *) ticket
{
    return [self.photo valueForKey:@"original_file"];
}

- (void) setTicket:(NSString *)ticket
{
    [self.photo setValue:ticket forKey:@"original_file"];
}

@end
