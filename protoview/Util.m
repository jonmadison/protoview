//
//  Util.m
//  protoview
//
//  Created by Madison, Jon on 8/13/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "Util.h"
#import <zipzap.h>
#import <GCDWebServer.h>


@implementation Util
- (id)init
{
  return [super init];
}
+ (void)createPrototypeDirectory:(NSString*)directoryPath {
  if(![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
    NSError* error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
      NSLog(@"%@",[error description]);
    }
  }
}


+ (void)copyPrototypeHTMLFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
  //create destination directory
  
//  NSString* destPath = [NSString stringWithFormat:@"%@/%@",toPath,fromPath];
  
  NSError* error = nil;
//  
//  NSString *sourcePath = [[NSBundle mainBundle] bundlePath];
//  NSString *bundleName = [NSString stringWithFormat:@"/%@.bundle",fromPath];
//  sourcePath = [sourcePath stringByAppendingString:bundleName];
  
  if([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
    if (![[NSFileManager defaultManager] removeItemAtPath:toPath error:&error])	//Delete it
		{
			NSLog(@"Delete directory error: %@", error);
		}
  }
  
  if (![[NSFileManager defaultManager]
        copyItemAtPath:fromPath
        toPath:toPath
        error:&error])
    NSLog(@"%@", [error localizedDescription]);
}


/*
 Download a file from a URL and return the destination path.
 */
//- (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;


+ (void)downloadFileNamed:(NSString*)fileName FromUrl:(NSURL*)url withCompletion:(void (^)(NSURL*, NSError*))completion {
  NSError* error = nil;
  NSURL *destinationURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
  [[NSFileManager defaultManager] createDirectoryAtURL:destinationURL withIntermediateDirectories:YES attributes:nil error:&error];
  if(error) {
    NSLog(@"error creating temp dir %@",[error localizedDescription]);
  }
  NSString* fullDownloadString = [NSString stringWithFormat:@"%@?dl=1",[url absoluteString]];
  NSURL* fullDownloadURL = [NSURL URLWithString:fullDownloadString];
  NSURLRequest* request = [NSURLRequest requestWithURL:fullDownloadURL];
  NSURLResponse* response = nil;

  NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  if(error) {
    return completion(nil,error);
  }
  NSURL *fileURL = [destinationURL URLByAppendingPathComponent:fileName];
  
  [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
  
  if(error) {
    NSLog(@"error writing downloaded file: %@",[error localizedDescription]);
    completion(nil,error);
  }
  
  completion(fileURL,nil);
  
}
@end
