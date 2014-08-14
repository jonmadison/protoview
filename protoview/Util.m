//
//  Util.m
//  protoview
//
//  Created by Madison, Jon on 8/13/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "Util.h"

@implementation Util
+ (void)createDirectory:(NSString*)directoryPath {
  if(![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
    NSError* error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (error) {
      NSLog(@"%@",[error description]);
    }
  }
}

+ (void)copyPrototypeHTMLFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
  //create destination directory
  
  NSString* destPath = [NSString stringWithFormat:@"%@/%@",toPath,fromPath];
  
  NSError* error = nil;
  
  NSString *sourcePath = [[NSBundle mainBundle] bundlePath];
  NSString *bundleName = [NSString stringWithFormat:@"/%@.bundle",fromPath];
  sourcePath = [sourcePath stringByAppendingString:bundleName];
  
  if([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
    if (![[NSFileManager defaultManager] removeItemAtPath:destPath error:&error])	//Delete it
		{
			NSLog(@"Delete directory error: %@", error);
		}
  }
  
  if (![[NSFileManager defaultManager]
        copyItemAtPath:sourcePath
        toPath:destPath
        error:&error])
    NSLog(@"%@", [error localizedDescription]);
}

@end
