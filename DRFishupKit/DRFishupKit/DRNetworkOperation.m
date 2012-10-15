//
//  DRNetworkOperation.m
//  DRFishupKit
//
//  Created by picasso on 09.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRNetworkOperation.h"

@interface DRNetworkOperation()
@property (assign, readwrite) NSInteger recCount;
@property (assign, readwrite) BOOL limitReached;
@property (strong, readwrite) NSError *fishupError;
@property (strong, readwrite) id responseFishup;
@end

@implementation DRNetworkOperation
@synthesize recCount = _recCount, limitReached = _limitReached, fishupError = _fishupError, responseFishup = _responseFishup;
@synthesize upload = _upload;

- (id)initWithURLString:(NSString *)aURLString params:(NSMutableDictionary *)params httpMethod:(NSString *)method
{
    self = [super initWithURLString:aURLString params:params httpMethod:method];
    if (self) {
        [self noError];
    }
    return self;
    
}

#pragma mark - Error processing

- (void) noError
{
    [self errorWithCode:0 info:nil underlyingError:nil];
}

- (void) errorWithCode:(NSInteger)code info:(NSDictionary *)params underlyingError:(NSError *)error
{
    if(self.fishupError != nil && code == 0 && self.fishupError.code == 0) return; // Nothing if no error occurred
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:params];
    NSString *description = [userInfo objectForKey:@"message"];
    NSString *details = [userInfo objectForKey:@"detail"];
    
    if(description == nil) description = @"Unknown error";
    
    [userInfo setObject:((code == 0) ? @"Everything's OK" : description) forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:((details == nil) ? @"" : details) forKey:NSLocalizedFailureReasonErrorKey];
    [userInfo removeObjectForKey:@"message"];
    [userInfo removeObjectForKey:@"detail"];
    [userInfo removeObjectForKey:@"errorcode"];
    
    if(error != nil) [userInfo setObject:error forKey:NSUnderlyingErrorKey];
    self.fishupError = [NSError errorWithDomain:kDRFishupAPIDomain code:code userInfo:userInfo];
}

- (BOOL) NOErrorWithData:(id)data
{
    BOOL wasOk = NO;
    
    @try {
        NSNumber *errcode = [data valueForKeyPath:@"error.errorcode"];
        
        if(errcode == nil  || [errcode intValue] == 0) {
            
            wasOk = YES;
            [self noError];
            
        } else
            [self errorWithCode:[errcode integerValue] info:[data valueForKeyPath:@"error"] underlyingError:nil];
    }
    
    @catch (NSException *e) {
        DLog(@"%@: %@", e.name, e.reason);
    }
    @finally {
        return wasOk;
    }
}


- (BOOL) scanWDDXError:(NSString *)string
{
    //NSLog(@"[%@]", string);
    
    BOOL isError = NO;
    NSCharacterSet *ltSet = [NSCharacterSet characterSetWithCharactersInString:@"<"];
    NSScanner *wddxScanner = [NSScanner scannerWithString:[NSString stringWithFormat:@" xxx %@", string]];
    
    NSString *WDDX = @"wddxPacket";
    NSString *ERROR = @"ERROR";
    NSString *MESSAGE = @"MESSAGE";
    NSString *DETAIL = @"DETAIL";
    NSString *ERRORCODE = @"ERRORCODE";
    NSString *STRING = @"string>";
    NSString *NUMBER = @"number>";
    
    NSString *eMessage, *eDetail;
    NSInteger errorCode;
 
    while ([wddxScanner isAtEnd] == NO)     {
        
        //        [wddxScanner setScanLocation:0];
        
        /*
         BOOL step = [wddxScanner scanUpToString:WDDX intoString:NULL];
         
         step = [wddxScanner scanUpToString:ERROR intoString:NULL];
         step = [wddxScanner scanUpToString:MESSAGE intoString:NULL];
         step = [wddxScanner scanUpToString:STRING intoString:NULL];
         step = [wddxScanner scanString:STRING intoString:NULL];
         step = [wddxScanner scanUpToCharactersFromSet:ltSet intoString:&eMessage];
         */
        
        if([wddxScanner scanUpToString:WDDX intoString:NULL] &&
           [wddxScanner scanUpToString:ERROR intoString:NULL] &&
           [wddxScanner scanUpToString:MESSAGE intoString:NULL] &&
           [wddxScanner scanUpToString:STRING intoString:NULL] &&
           [wddxScanner scanString:STRING intoString:NULL]) {
            
            isError = YES;
            if([wddxScanner scanUpToCharactersFromSet:ltSet intoString:&eMessage] == NO)
                eMessage = @"";
        }
        break;
    }
    
    if(isError) {
        
        [wddxScanner setScanLocation:0];
        while ([wddxScanner isAtEnd] == NO)     {
            
            if([wddxScanner scanUpToString:ERROR intoString:NULL] &&
               [wddxScanner scanUpToString:DETAIL intoString:NULL] &&
               [wddxScanner scanUpToString:STRING intoString:NULL] &&
               [wddxScanner scanString:STRING intoString:NULL]) {
                
                isError = YES;
                if([wddxScanner scanUpToCharactersFromSet:ltSet intoString:&eDetail] == NO)
                    eDetail = @"";
            }
            break;
        }
    }
    
    if(isError) {
        
        [wddxScanner setScanLocation:0];
        while ([wddxScanner isAtEnd] == NO)     {
            
            if([wddxScanner scanUpToString:ERROR intoString:NULL] &&
               [wddxScanner scanUpToString:ERRORCODE intoString:NULL] &&
               [wddxScanner scanUpToString:NUMBER intoString:NULL] &&
               [wddxScanner scanString:NUMBER intoString:NULL]) {
                if([wddxScanner scanInteger:&errorCode] == NO)
                    errorCode = 0;
                isError = YES;
            }
            break;
        }
    }

    if(isError)
        [self errorWithCode:errorCode
                       info:[NSDictionary dictionaryWithObjectsAndKeys:eMessage, @"message", eDetail, @"detail", nil]
            underlyingError:nil];
    
    return isError;
}


#pragma mark - Fishup Response processing

-(void) operationSucceeded
{
    self.responseFishup = [self processFishup];
    
    if(self.fishupError.code == 0)
        [super operationSucceeded];
    else
        [super operationFailedWithError:self.fishupError];
}

-(void) operationFailedWithError:(NSError*)error
{
    NSError *combinedError = error;
    if([self responseData] != nil) {
        
        NSError *jsonerror = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[self responseData] options:0 error:&jsonerror];
        
        if(jsonerror == nil && jsonData != nil) {
            NSNumber *errcode = [jsonData objectForKey:@"errorcode"];
            if(errcode != nil && [errcode integerValue] != 0) {
                NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                [userInfo addEntriesFromDictionary:jsonData];
                
                [self errorWithCode:[errcode integerValue] info:jsonData underlyingError:error];
                combinedError = self.fishupError;
            }
        }
    }
    [super operationFailedWithError:combinedError];
}

- (id) processFishup
{
    if([self responseData] == nil) return nil;
    
    NSError *error = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[self responseData] options:0 error:&error];

    if(error || jsonData == nil) {
        
        [self scanWDDXError:[self responseString]];
        return [self responseString];
    }
    
    id processedData = jsonData;
    
    @try {
        if([self NOErrorWithData:jsonData]) {
            NSNumber *recCount = [jsonData valueForKeyPath:@"record_count"];
            NSNumber *limit = [jsonData valueForKeyPath:@"max_limit_reached"];
            if(recCount == nil) {
                self.recCount = -1; // it's not CFQuery!
                self.limitReached = NO;
                processedData = [self responseStruct:jsonData];
            } else {
                self.recCount = [recCount integerValue];
                self.limitReached = ([limit integerValue] == 0) ? NO : YES;
                if(self.recCount > 0)
                    processedData = [self responseQuery:jsonData];
                else
                    processedData = [NSArray array];
            }
        }
    }
    @catch (NSException *e) {
        DLog(@"%@: %@", e.name, e.reason);
    }
    @finally {
        return processedData;
    }
 }

- (NSString *) responseString
{
    NSCharacterSet *quotes = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    return [[super responseString] stringByTrimmingCharactersInSet:quotes];
}

- (id) responseStruct:(NSDictionary *)jsonData
{
    id processedData = jsonData;

    @try {
        NSDictionary *data = [jsonData valueForKey:@"data"];
        
        if(data != nil) {
            
            BOOL isImageIncluded = NO;
            NSMutableDictionary *structData = [data mutableCopy];
            
            for(NSString *key in data)
            {
                id value = [data valueForKey:key];
                NSMutableArray *thumbs = [[key componentsSeparatedByString:@"_"] mutableCopy];
                
                if([thumbs count] > 1 && [thumbs containsObject:@"file"]) {
                    
                    if(isImageIncluded == NO) {
                        isImageIncluded = YES;
                        [structData setValue:[NSMutableDictionary dictionary] forKey:@"photo"];
                    }
                    
                    [thumbs removeLastObject];
                    NSString *thumb = [thumbs componentsJoinedByString:@""];
                    NSArray *info = [self arrayFromString:value];
                    NSMutableDictionary *image = [NSMutableDictionary dictionary];
                    
                    if([[info objectAtIndex:0] length])
                        [image setValue:[kDRFishupImageHost stringByAppendingString:[info objectAtIndex:0]] forKey:@"url"];
                    else
                         [image setValue:[info objectAtIndex:0] forKey:@"url"];
 
                    [image setValue:[info objectAtIndex:2] forKey:@"width"];
                    [image setValue:[info objectAtIndex:3] forKey:@"height"];
                    [image setValue:[NSNumber numberWithDouble:[[info objectAtIndex:4] doubleValue]/1024] forKey:@"size"];
                    [image setValue:[info objectAtIndex:5] forKey:@"name"];
                    
                    [structData removeObjectForKey:key];
                    [structData setValue:image forKeyPath:[@"photo." stringByAppendingString:thumb]];
                } else {
                    
                    [structData removeObjectForKey:key];
                    [structData setValue:value forKey:[key lowercaseString]];
                }
            }
            processedData = structData;
        }
    }
    @catch (NSException *e) {
        DLog(@"%@: %@", e.name, e.reason);
    }
    @finally {
        return processedData;
    }
}

- (NSArray *) arrayFromString:(NSString *)string
{
    NSArray *empty = [NSArray arrayWithObjects:@"", @"", @"0", @"0", @"0", @"", nil];
    NSArray *data = [string componentsSeparatedByString:@"|"];
    
    return ([string length] && [data count] >= 6) ? data : empty;
}

- (id) responseQuery:(NSDictionary *)jsonData
{
    id processedData = jsonData;
    
    @try {
        NSMutableArray *query = [NSMutableArray array];
        NSString *exceptionReason = nil;
        NSArray *columns = [[jsonData valueForKeyPath:@"data.columnlist"] componentsSeparatedByString:@","];
        NSDictionary *data = [jsonData valueForKeyPath:@"data.data"];
        NSInteger recordCount = [[jsonData valueForKeyPath:@"data.recordcount"] integerValue];
        
        if(recordCount == 0) exceptionReason = @"Value for key='data.recordcount' is zero";
        if(columns == nil) exceptionReason = @"Value for key='data.columnlist' is not found";
        if(data == nil) exceptionReason = @"Value for key='data.data' is not found";
        
        if(exceptionReason != nil)
            @throw [NSException exceptionWithName:@"CFQueryParsingError" reason:exceptionReason userInfo:nil];
        
        for(NSInteger i=0; i < recordCount; i++) {
            
            BOOL isImageIncluded = NO;
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            for(NSString *column in columns)
            {
                NSString *key = [column lowercaseString];
                id value = [[data valueForKey:column] objectAtIndex:i];
                
                if([key isEqualToString:@"id"]) value = [value stringValue];
                
                NSMutableArray *thumbs = [[key componentsSeparatedByString:@"_"] mutableCopy];
                if([thumbs count] > 1 && [thumbs containsObject:@"file"]) {
                    
                    if(isImageIncluded == NO) {
                        isImageIncluded = YES;
                        [item setValue:[NSMutableDictionary dictionary] forKey:@"photo"];
                    }
                    
                    [thumbs removeLastObject];
                    NSString *thumb = [thumbs componentsJoinedByString:@""];
                    NSArray *info = [value componentsSeparatedByString:@"|"];
                    NSMutableDictionary *image = [NSMutableDictionary dictionary];
                    
                    [image setValue:[kDRFishupImageHost stringByAppendingString:[info objectAtIndex:0]] forKey:@"url"];
                    [image setValue:[info objectAtIndex:2] forKey:@"width"];
                    [image setValue:[info objectAtIndex:3] forKey:@"height"];
                    [image setValue:[NSNumber numberWithDouble:[[info objectAtIndex:4] doubleValue]/1024] forKey:@"size"];
                    [image setValue:[info objectAtIndex:5] forKey:@"name"];
                    
                    
                    value = image;
                    key = [@"photo." stringByAppendingString:thumb];
                }
                [item setValue:value forKeyPath:key];
            }
            [query addObject:item];
        }
        processedData = query;
    }
    
    @catch (NSException *e) {
        DLog(@"%@: %@", e.name, e.reason);
    }
    @finally {
        return processedData;
    }
}

@end
