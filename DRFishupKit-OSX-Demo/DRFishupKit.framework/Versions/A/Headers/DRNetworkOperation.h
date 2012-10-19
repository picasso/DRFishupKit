//
//  DRNetworkOperation.h
//  DRFishupKit
//
//  Created by picasso on 09.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRFishupKit.h"

@interface DRNetworkOperation : MKNetworkOperation
@property (assign, readonly) NSInteger recCount;
@property (assign, readonly) BOOL limitReached;
@property (strong, readonly) NSError *fishupError;
@property (strong, readonly) id responseFishup;
@property (strong) DRUploadFile *upload;

-(void) operationSucceeded;

@end
