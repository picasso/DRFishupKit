//
//  DRFishupEngine.h
//  DRFishupKit
//
//  Created by picasso on 02.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

@interface DRFishupEngine : MKNetworkEngine

@property (assign) BOOL isNetworkActive;
@property (strong) NSString *token;
@property (strong) NSString *uploadGallery;

@property (assign) NSInteger page;
@property (assign) NSInteger perPage;
@property (assign, readonly) NSInteger recCount;
@property (assign, readonly) BOOL limitReached;


- (void) onNetworked:(DRVoidBlock)block;
- (void) onError:(DRErrorBlock)block;
- (void) onProgress:(DRProgressBlock)block;

- (void) login:(NSString *)login password:(NSString *)pass;
- (BOOL) login:(NSString *)login password:(NSString *)pass andWait:(BOOL)wait;
- (void) logout;

- (void) sendAPI:(NSString *)api onCompletion:(DRDataBlock)dataBlock;
- (void) sendAPI:(NSString *)api withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock;
- (void) sendAPI:(NSString *)api method:(NSString *)method withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock;
- (void) postAPI:(NSString *)api withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock;
- (void) postAPI:(NSString *)api method:(NSString *)method withParams:(NSDictionary *)params onCompletion:(DRDataBlock)dataBlock;


- (DRUploadFile *) uploadForPath:(NSString *)path;
- (DRUploadFile *) uploadForTicket:(NSString *)ticket;
- (void) addUpload:(id)file;
- (void) addUploads:(NSArray *)files;
- (void) uploadToGallery:(NSString *)galleryId onCompletion:(DRArrayBlock)dataBlock;




- (void) userPublicData:(NSString *)userId onCompletion:(DRDataBlock)dataBlock;



/*

- (void) testForArguments:(NSDictionary *)args onCompletion:(FishupDataBlock) imageURLBlock onError:(MKNKErrorBlock) errorBlock;

- (void) imagesFor:(NSDictionary *)args onCompletion:(FishupQueryDataBlock)queryBlock onError:(MKNKErrorBlock) errorBlock;

*/


- (NSArray *) onlyJpeg;
- (BOOL) isJpeg:(NSString *)path;

@end
