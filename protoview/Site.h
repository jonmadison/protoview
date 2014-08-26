//
//  Site.h
//  protoview
//
//  Created by Madison, Jon on 8/17/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Site : NSObject
@property NSString* identifier;
@property NSString* friendlyName;
@property NSDate* createdAt;
@property UIImage* thumbnail;
@property (getter = isEditable) BOOL editable;
- (NSData*)asData;
+ (Site*)objectFromData:(NSData*)data;
@end
