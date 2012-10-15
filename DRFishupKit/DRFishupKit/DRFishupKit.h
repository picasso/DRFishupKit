//
//  DRFishupKit.h
//  DRFishupKit
//
//  Created by picasso on 09.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#ifndef DRFishupKit_DRFishupKit_h
#define DRFishupKit_DRFishupKit_h

typedef void (^DRVoidBlock)();
typedef void (^DRErrorBlock)(NSError *);
typedef void (^DRDataBlock)(id data);
typedef void (^DRArrayBlock)(NSArray *array);
typedef void (^DRParamBlock)(NSMutableDictionary *array);
typedef void (^DRProgressBlock)(double progress);

#define kDRFishupRESTAPIEndpoint		@"www.fishup.ru"
#define kDRFishupAPIDomain              @"ru.fishup.api"
#define kDRFishupImageHost				@"http://static.fishup.ru"
#define kDRFishupSecurityAPI			@"misc.security"
#define ofuFishupHost					@"http://www.fishup.ru"

#define kDRFishupRecordsPerPage         50

#import "MKNetworkKit.h"
#import "DRUploadFile.h"
#import "DRFishupAPIHelper.h"
#import "DRFishupEngine.h"
#import "DRNetworkOperation.h"


#endif


