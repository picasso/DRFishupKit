//
//  DRXDImageCell.h
//  DRFishupKit-OSX-Demo
//
//  Created by picasso on 16.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRXDImageCell : NSObject
@property (strong) NSURL* url;
@property (strong) NSString *title;
@property (strong) NSString *subtitle;
@property (strong) NSString *oid;
@property (strong) NSImage *image;
@end
