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
  self.identifier = [[NSUUID UUID] UUIDString];
  return self;
}

- (NSData*)asData
{
  return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (Site*)objectFromData:(NSData*)data
{
  id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  return (Site*)obj;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.friendlyName forKey:@"SiteFriendlyName"];
  [coder encodeObject:self.identifier forKey:@"SiteURL"];
  [coder encodeObject:self.createdAt forKey:@"SiteCreatedAt"];
  [coder encodeObject:self.thumbnail forKey:@"SiteThumbnail"];
}

- (id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self) {
    self.friendlyName = [coder decodeObjectForKey:@"SiteFriendlyName"];
    self.identifier = [coder decodeObjectForKey:@"SiteURL"];
    self.createdAt = [coder decodeObjectForKey:@"SiteCreatedAt"];
    self.thumbnail = [coder decodeObjectForKey:@"SiteThumbnail"];
  }
  return self;
}
@end
