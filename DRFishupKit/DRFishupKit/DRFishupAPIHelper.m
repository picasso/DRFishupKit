//
//  DRFishupAPIHelper.m
//  DRFishupKit
//
//  Created by picasso on 09.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRFishupAPIHelper.h"

@interface DRFishupAPIHelper ()
@property (strong) NSDictionary	*helper;
@property (copy) DRParamBlock extendParams;
@property (weak) DRFishupEngine *engine;

- (NSDictionary *) apiForKey:(NSString *)key;
- (NSMutableDictionary *) paramsForKey:(NSString *)key;
- (NSString *) JSONString:(NSString *)string;
- (NSMutableDictionary *) JSONParams:(NSDictionary *)params forPOST:(BOOL)forPOST;
@end

@implementation DRFishupAPIHelper
@synthesize helper = _helper, extendParams = _extendParams;

- (id)init
{
    self = [super init];
    if (self) {
        self.helper = [[NSDictionary alloc] initWithContentsOfFile:
                       [[NSBundle bundleForClass:[self class]] pathForResource:@"ApiHelpers" ofType: @"plist"]];
    }
    return self;
}

- (void) extendParams:(DRParamBlock)block
{
    self.extendParams = block;
}

#pragma mark - Convenience methods

- (NSString *) JSONString:(NSString *)string
{
	NSMutableString *s = [[NSString stringWithFormat:@"%@", string] mutableCopy];
	[s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	return [NSString stringWithFormat:@"\"%@\"", s];
}

- (NSMutableDictionary *) JSONParams:(NSDictionary *)params forPOST:(BOOL)forPOST
{
    NSMutableDictionary *jsonParams = [NSMutableDictionary dictionary];
    
    for(NSString *key in params) {
        id param = [params objectForKey:key];
        
        if([param isKindOfClass:[NSDictionary class]] || [param isKindOfClass:[NSArray class]])
            param = [param jsonEncodedKeyValueString];
        else if([param isKindOfClass:[NSNumber class]])
            param = [param stringValue];
        else if([param isKindOfClass:[NSString class]])
            param = forPOST ? [self JSONString:param] : [param stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        else
            param = [NSString stringWithFormat:@"%@", param];
        
        [jsonParams setObject:param forKey:key];
    }
    return jsonParams;
}

- (NSDictionary *) apiForKey:(NSString *)key
{
    return [self.helper valueForKeyPath:key];
}

- (NSMutableDictionary *) paramsForKey:(NSString *)key
{
    return [[[self apiForKey:key] valueForKeyPath:@"params"] mutableCopy];
}

#pragma mark - API Helpers methods for GET requests

- (NSString *) stringForAPI:(NSString *)api extendWith:(NSDictionary *)params
{
    NSString *errorMessage = nil;
    NSString *apiString = [[self apiForKey:api] objectForKey:@"method"];
    NSMutableDictionary *apiParams = [self paramsForKey:api];
    
    if(apiString == nil) {
        errorMessage = [NSString stringWithFormat:@"ApiHelper not found for %@!", api];
        apiString = api;
    }

    if(apiParams == nil) apiParams = [NSMutableDictionary dictionary];
    [apiParams addEntriesFromDictionary:params];
    apiString = [self stringForAPI:[apiString componentsSeparatedByString:@"."] params:apiParams];
    
    if(apiString == nil) {
        if(errorMessage) { DLog(@"%@ and %@ doesn't look as correct API call", errorMessage, api);}
        else { DLog(@"ApiHelper for %@ doesn't look to be correct", api);}
    }
    return apiString;
}

- (NSString *) stringForAPI:(NSArray *)api params:(NSDictionary *)params
{
    if([api count] == 3) {
        NSString *stringParams = [NSString string];
        NSMutableDictionary *sendParams = [params mutableCopy];
        
        if(self.extendParams) self.extendParams(sendParams);
        
        if(sendParams != nil && [sendParams count] != 0) {
            NSMutableArray *requestParams = [[NSMutableArray alloc] initWithCapacity:[sendParams count]];
            
            [[self JSONParams:sendParams forPOST:NO] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
              [requestParams addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
            }];
            
            stringParams = [NSString stringWithFormat:@"&%@",[requestParams componentsJoinedByString:@"&"]];
        }

        return [NSString stringWithFormat:@"api/%@/%@.cfc?method=%@%@&encoding=json",
                [api objectAtIndex:0], [api objectAtIndex:1], [api objectAtIndex:2], stringParams];
    }
    return nil;
}

#pragma mark - API Helpers methods for POST requests

- (NSMutableDictionary *) paramsFromDict:(NSDictionary *)args
{
    return [self paramsFromDict:args asJSON:YES];
}

- (NSMutableDictionary *) paramsFromDict:(NSDictionary *)args asJSON:(BOOL)asJSON
{
    NSMutableDictionary *postParams = [args mutableCopy];
    if(self.extendParams) self.extendParams(postParams);
    return asJSON ? [self JSONParams:postParams forPOST:YES] : postParams;
}

- (NSString *) stringForAPI:(NSString *)api
{
    NSString *apiString = [[self apiForKey:api] objectForKey:@"method"];
    
    if(apiString == nil) apiString = api;
    NSArray *package = [apiString componentsSeparatedByString:@"."];
    
    if([package count] == 3)
        return [NSString stringWithFormat:@"api/%@/%@.cfc?method=%@&encoding=json",
                [package objectAtIndex:0], [package objectAtIndex:1], [package objectAtIndex:2]];
    else
        return nil;
}

- (NSString *) stringFromAPI:(NSString *)api method:(NSString *)method
{
    return [api stringByAppendingFormat:@".%@", method];
}

@end

