//
//  DRXDImageCell.m
//  DRFishupKit-OSX-Demo
//
//  Created by picasso on 16.10.12.
//  Copyright (c) 2012 Dmitry Rudakov. All rights reserved.
//

#import "DRXDImageCell.h"
#import <Quartz/Quartz.h>

@implementation DRXDImageCell
@synthesize url = _url, title = _title, subtitle = _subtitle, image = _image, oid = _oid;

- (id) init
{
    self = [super init];
    if (self) {
        self.title = @"";
        self.subtitle = @"";
    }
    return self;
}

#pragma mark - IKImageBrowserItem Protocol methods

- (NSString *)  imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)  imageRepresentation
{
    return self.image;
}

- (NSString *) imageUID
{
    return [NSString stringWithFormat:@"%p", self.url]; // pointer printed in hexadecimal with a leading 0x
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"DRXDImageCell: title:%@ subtitle=%@ url:%@ id:%@ (%@)",
            self.title,
            self.subtitle,
            [self.url path],
            self.oid,
            self.image];
}

- (NSString *) imageTitle
{
    return self.title;
}

- (NSString *) imageSubtitle
{
    return self.subtitle;
}

@end
