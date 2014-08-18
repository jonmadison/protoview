//
//  Site.m
//  protoview
//
//  Created by Madison, Jon on 8/17/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "Site.h"

@implementation Site
- (id)init {
  self = [super init];
  self.url = [[NSUUID UUID] UUIDString];
  return self;
}
@end
