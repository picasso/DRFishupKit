//
//  DRFishupAPIHelper.h
//  DRFishupKit
//
//  Created by picasso on 09.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

@interface DRFishupAPIHelper : NSObject

- (void) extendParams:(DRParamBlock)block;

- (NSString *) stringFromAPI:(NSString *)api method:(NSString *)method;

- (NSString *) stringForAPI:(NSString *)api extendWith:(NSDictionary *)params;
- (NSString *) stringForAPI:(NSArray *)api params:(NSDictionary *)params;

- (NSString *) stringForAPI:(NSString *)api;
- (NSMutableDictionary *) paramsFromDict:(NSDictionary *)args;
- (NSMutableDictionary *) paramsFromDict:(NSDictionary *)args asJSON:(BOOL)asJSON;

@end
