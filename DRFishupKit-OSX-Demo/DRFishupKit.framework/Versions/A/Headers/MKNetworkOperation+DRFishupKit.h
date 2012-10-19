//
//  MKNetworkOperation+DRFishupKit.h
//  DRFishupKit
//
//  Created by picasso on 09.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//


@interface MKNetworkOperation (DRFishupKit)
- (BOOL) NOErrorWithData:(id)data onError:(MKNKErrorBlock)errorBlock;
- (id) responseFishup:(MKNKErrorBlock) errorBlock;
- (id) responseStruct:(NSDictionary *)jsonData;
- (id) responseQuery:(NSDictionary *)jsonData;
@end
