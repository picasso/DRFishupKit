//
//  DRFishupEngine.m
//  DRFishupKit
//
//  Created by picasso on 02.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRFishupEngine.h"

@interface DRFishupEngine()

@property (copy) NSDate *start;
@property (copy) NSDate *uploadstart;
@property (copy) NSDate *addstart;
@property (copy) NSDate *stop;


@property (copy) DRVoidBlock networkedBlock;
@property (copy) DRErrorBlock errorBlock;
@property (copy) DRProgressBlock progressBlock;
@property (copy) DRArrayBlock uploadBlock;


@property (strong) DRFishupAPIHelper *helper;
@property (assign, readwrite) NSInteger recCount;
@property (assign, readwrite) BOOL limitReached;
@property (strong) NSMutableArray *queue;
@property (assign) NSInteger queueSize;
@property (assign) BOOL waitingForToken;

- (void) prepareUpload:(DRUploadFile *)file;
- (void) doUpload:(DRUploadFile *)file url:(NSString *)url;
- (void) registerUpload:(DRUploadFile *)file;

@end

@implementation DRFishupEngine
@synthesize token = _token, uploadGallery = _uploadGallery, page = _page, perPage = _perPage, waitingForToken = _waitingForTokens;
@synthesize recCount = _recCount, limitReached = _limitReached;
@synthesize networkedBlock = _networkedBlock, errorBlock = _errorBlock, progressBlock = _progressBlock, uploadBlock = _uploadBlock;
@synthesize isNetworkActive = _isNetworkActive, helper = _helper, queue = _queue, queueSize = _queueSize;

@synthesize start, uploadstart, addstart, stop;

- (id)init
{
    self = [super initWithHostName:kDRFishupRESTAPIEndpoint customHeaderFields:nil];
    if (self) {
        
        self.page = 1;
        self.perPage = kDRFishupRecordsPerPage;
        self.isNetworkActive = NO;
        self.queue = [NSMutableArray array];
      
        [self onError:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(networkActivity:) name:kMKNetworkEngineOperationCountChanged object:nil];
        
        [self registerOperationSubclass:([DRNetworkOperation class])];
        [self useCache];
        
        self.helper = [[DRFishupAPIHelper alloc] init];
        [self.helper extendParams:^(NSMutableDictionary *params) {
        
            if([self.token length]) [params setObject:self.token forKey:@"token"];
            [params setObject:[NSNumber numberWithInteger:self.page] forKey:@"page"];
            [params setObject:[NSNumber numberWithInteger:self.perPage] forKey:@"rec_per_page"];
        }];
        
    }
    return self;
}

#pragma mark - Network Activity observing via KVO for network Queue

- (void) onNetworked:(DRVoidBlock)block
{
    self.networkedBlock = block;
}

- (void) networkActivity: (NSNotification *) notification {
    
    BOOL isActivite = [notification.object integerValue] > 0 ? YES : NO;
    
    if(self.isNetworkActive != isActivite) {
        
        self.isNetworkActive = isActivite;
        if(self.networkedBlock != nil) self.networkedBlock();
    }
}

#pragma mark - Error processing

- (void) onError:(DRErrorBlock)block
{
    self.errorBlock = ^(NSError *error) {
        
        if(block != nil) block(error);
        else { DLog(@"\nFishup Error:\n%@\n", error);}
    };
}

#pragma mark - Login/Logout Methods

- (void) login:(NSString *)login password:(NSString *)pass
{
    [self login:login password:pass andWait:NO];
}

- (BOOL) login:(NSString *)login password:(NSString *)pass andWait:(BOOL)wait
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:login, @"login", pass, @"pwd", nil];
    self.waitingForToken = wait;
    
    [self postAPI:kDRFishupSecurityAPI method:@"login" withParams:params onCompletion:^(id data){
        
        self.token = (NSString *)data;
        self.waitingForToken = 0;
        DLog(@"LOGIN token %@%@", [self.token length] ? @"received:" : @"empty", self.token);
    }];
    
    if(wait) {
        NSDate *loopStarted = [NSDate date];
        NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:kMKNetworkKitRequestTimeOutInSeconds];
        
        while([loopUntil timeIntervalSinceNow] > 1.0) {
            
            if(self.waitingForToken == 0) break;
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: loopUntil]; //[NSDate distantFuture]];
        }
        
        if(self.waitingForToken == 1)
            {DLog(@"The server took longer than %d sec to provide data [timeout].", abs([loopStarted timeIntervalSinceNow]));}
    }
    return ([self.token length] == 0) ? NO :YES;
}

- (void) logout
{
    if([self.token length])
        [self sendAPI:kDRFishupSecurityAPI method:@"logout" withParams:nil onCompletion:^(id data){ self.token = nil;}];
}

#pragma mark - General GET API methods

- (void) sendAPI:(NSString *)api onCompletion:(DRDataBlock)dataBlock
{
    [self sendAPI:api withParams:nil onCompletion:dataBlock];
}

- (void) sendAPI:(NSString *)api withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock
{
    [self processPath:[self.helper stringForAPI:api extendWith:params] params:nil http:@"GET" onCompletion:dataBlock];
}

- (void) sendAPI:(NSString *)api method:(NSString *)method withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock
{
    NSString *apiString = [self.helper stringFromAPI:api method:method];
    [self sendAPI:apiString withParams:params onCompletion:dataBlock];
}

#pragma mark - General POST API methods

- (void) postAPI:(NSString *)api withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock
{
    NSMutableDictionary *requestParams = [self.helper paramsFromDict:params];
    [self processPath:[self.helper stringForAPI:api] params:requestParams http:@"POST" onCompletion:dataBlock];
}

- (void) postAPI:(NSString *)api method:(NSString *)method withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock
{
    NSString *apiString = [self.helper stringFromAPI:api method:method];
    [self postAPI:apiString withParams:params onCompletion:dataBlock];
}

#pragma mark - Processing requests

- (void) processPath:(NSString *)path params:(NSMutableDictionary *)params http:(NSString *)http onCompletion:(DRDataBlock)dataBlock
{
    if(path != nil) {
        MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:http];
        
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            
            NSLog(@"%@", completedOperation.isCachedResponse ? @"from cache" : @"live");
            DRNetworkOperation *completed = (DRNetworkOperation *)completedOperation;
            id response = [completed responseFishup];
            dataBlock(response);
            
        } onError:^(NSError *error) {
            
            self.errorBlock(error);
        }];
        
        [self enqueueOperation:op];
    }
}

#pragma mark - Upload file methods

- (void) prepareUpload:(DRUploadFile *)file
{
    self.start = [NSDate date];
    NSMutableDictionary *postParams = [self.helper paramsFromDict:[file prepareUploadParams]];
    [self processUpload:file path:[self.helper stringForAPI:@"misc.file.prepareUpload"] params:postParams asJSON:YES];
}

- (void) doUpload:(DRUploadFile *)file url:(NSString *)url
{
    self.uploadstart = [NSDate date];
    if(self.progressBlock) self.progressBlock(0); // we do not use this value
    NSMutableDictionary *postParams = [self.helper paramsFromDict:[file uploadParams] asJSON:NO];
    [self processUpload:file path:url params:postParams asJSON:NO];
}

- (void) registerUpload:(DRUploadFile *)file
{
    self.addstart = [NSDate date];
    if(self.progressBlock) self.progressBlock(0); // we do not use this value
    NSMutableDictionary *postParams = [self.helper paramsFromDict:[file addParams:self.uploadGallery]];
    [self processUpload:file path:[self.helper stringForAPI:@"galleries.gobject.add"] params:postParams asJSON:YES];
}

- (void) processUpload:(DRUploadFile *)file path:(NSString *)path params:(NSMutableDictionary *)params asJSON:(BOOL)asJSON
{
    if(path != nil) {
        MKNetworkOperation *op;
        
        if(!asJSON) {
            
            op = [self operationWithURLString:path params:params httpMethod:@"POST"];
            [op addFile:file.filepath forKey:@"data" mimeType:@"image/jpeg"];
            [op onUploadProgressChanged:^(double progress) {
                [file updateUploadProgress:progress];
                if(self.progressBlock) self.progressBlock(progress);
                //DLog(@"%.2f", progress*100.0);
            }];

        } else
            op = [self operationWithPath:path params:params httpMethod:@"POST"];
 
        // TODO: setFreezable uploads our images after connection is restored!
        //[op setFreezable:YES];
        
        ((DRNetworkOperation *)op).upload = file;
        
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            
            DRNetworkOperation *completed = (DRNetworkOperation *)completedOperation;
            DRUploadFile *file = completed.upload;
            id response = [completed responseFishup];
            
            if(file.isPreparing) {
                [file prepareCompleted:response];
                [self doUpload:file url:file.uploadURL];
            } else
                if(file.isUploading) {
                    [file uploadCompleted:response];
                    [self registerUpload:file];
                } else
                    if(file.isAdding) {
                        
                        [file addCompleted:response];
                        if(self.progressBlock) self.progressBlock(0); // we do not use this value
                        
                        self.stop = [NSDate date];
                        NSTimeInterval full = [self.stop timeIntervalSinceDate:self.start];
                        NSLog(@"\n ----(%ld Kb)---\n  full=%.2fs\n  prepare=%.2fs (%.0f%%)\n  upload=%.2fs (%.0f%%)\n  add=%.2fs (%.0f%%)\n\n",
                              file.filesize/1024,
                              full,
                              [self.uploadstart timeIntervalSinceDate:self.start],
                              [self.uploadstart timeIntervalSinceDate:self.start]/full*100,
                              [self.addstart timeIntervalSinceDate:self.uploadstart],
                              [self.addstart timeIntervalSinceDate:self.uploadstart]/full*100,
                              [self.stop timeIntervalSinceDate:self.addstart],
                              [self.stop timeIntervalSinceDate:self.addstart]/full*100
                           );
                        
                        [self nextUpload];
                    } else
                        DLog(@"Strange! Upload operation completed for %@?", file);
            
        } onError:^(NSError *error) {
            
            self.errorBlock(error);
        }];
        
        [self enqueueOperation:op];
    }
}


#pragma mark - Upload Queue methods

- (void) onProgress:(DRProgressBlock)block
{
    self.progressBlock = ^(double progress) {
    
        double progressSize = 0;
        for(DRUploadFile *file in self.queue)
            progressSize += file.filesize * file.fileProgress;
        
        if(block) block(progressSize/self.queueSize);
    };
}

- (void) dealloc
{
    // TODO: cancel
}

- (DRUploadFile *) uploadForPath:(NSString *)path
{
    for(DRUploadFile *file in self.queue)
        if([file.filepath isEqualToString:path])
            return file;
    
    return nil;
}

- (DRUploadFile *) uploadForTicket:(NSString *)ticket
{
    for(DRUploadFile *file in self.queue)
        if([file.ticket isEqualToString:ticket])
            return file;
    
    return nil;
}

- (void) addUpload:(id)file
{
    NSString *filepath = [file isKindOfClass:[NSURL class]] ? [file path] : ([file isKindOfClass:[NSString class]] ? file : nil);
    
    if(filepath) {
        DRUploadFile *ufile = [[DRUploadFile alloc] initWithPath:filepath];
        
        if(ufile.filesize != 0 && [self isJpeg:filepath])
            [self.queue addObject:ufile];
    } else
        DLog(@"Upload should be either NSString or NSURL, but it's [%@]", [file class]);
}

- (void) addUploads:(NSArray *)files
{
    for(id file in files)
        [self addUpload:file];
}

- (void) uploadToGallery:(NSString *)galleryId onCompletion:(DRArrayBlock)dataBlock
{
    if([self.token length] ==0) {
        DLog(@"Upload for authorized users only: token empty");
        return;
    }
 
    if([galleryId length] ==0) {
        DLog(@"Cannot upload without gallery ID");
        return;
    }

    self.uploadGallery = galleryId;
    [self calculateQueueSize];
    
    if(self.queueSize == 0) {
        DLog(@"Cannot upload because the queue is empty (no accepted files found)");
        return;
    }
    
    self.uploadBlock = dataBlock;
    [self nextUpload];
}

- (void) nextUpload
{
    DRUploadFile *file = nil;
    
    for(file in self.queue)
        if([file.ticket isEqual:[NSNull null]]) {
            
            [file onCompleted:^(id data) {
                NSLog(@"file %@ completed", file.title);
            }];
            
            [self prepareUpload:file];
            return;
        }
    
    // Upload queue completed! - clean uploadBlock for the next calls
    
    if(self.uploadBlock) {
        self.uploadBlock(self.queue);
        self.uploadBlock = nil;
    }
}

// TODO: make clean queue after upload
- (void) clean
{
}

#pragma mark - Helpers methods

- (NSString*) cacheDirectoryName
{
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *appCacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName];
    
    return [appCacheDirectory stringByAppendingPathComponent:kDRFishupAPIDomain];
}

- (void) calculateQueueSize
{
    for(DRUploadFile *file in self.queue)
        self.queueSize += file.filesize;
}

- (NSArray *) onlyJpeg
{
    return [NSArray arrayWithObjects:@"jpg", @"JPG", @"jpeg", @"JPEG", @"'JPEG'", nil];
}

- (BOOL) isJpeg:(NSString *)path
{
    return [[self onlyJpeg] containsObject:[path pathExtension]];
}
















#pragma mark - Convenience API Methods

- (void) userPublicData:(NSString *)userId onCompletion:(DRDataBlock)dataBlock
{
    [self sendAPI:@"user.public" withParams:[NSDictionary dictionaryWithObject:userId forKey:@"id"] onCompletion:dataBlock];
}


//    NSDictionary *a2 = [NSDictionary dictionaryWithObjectsAndKeys:@"3031", @"id", nil];
//    [self callAPI:@"accounts.user" method:@"getPublicData" arguments:a2 onCompletion:dataBlock onError:errorBlock];

//    NSDictionary *a2 = [NSDictionary dictionaryWithObjectsAndKeys:@"1393711", @"id", nil];
//    [self callAPI:@"galleries.gallery" method:@"getData" arguments:a2 onCompletion:dataBlock onError:errorBlock];

//    [self callAPI:@"misc.test" method:@"getArray" arguments:nil onCompletion:dataBlock onError:errorBlock];


//- (void) imagesFor:(NSDictionary *)args onCompletion:(FishupQueryDataBlock)queryBlock onError:(MKNKErrorBlock)errorBlock
//{
//    [self callAPI:@"galleries.gobject" method:@"select" arguments:args onCompletion:queryBlock];
//
//
//    NSString *request = [self stringForAPI:@"galleries.gobject" method:@"select" arguments:args];
//
//    MKNetworkOperation *op = [self operationWithPath:request];
//
//    [op onCompletion:^(MKNetworkOperation *completedOperation) {
//
//        NSArray *response = [completedOperation responseQuery];
//        imageURLBlock(response); // [[response objectForKey:@"photos"] objectForKey:@"photo"]);
//
//    } onError:^(NSError *error) {
//
//        errorBlock(error);
//    }];
//
//    [self enqueueOperation:op];
//
//}


@end

