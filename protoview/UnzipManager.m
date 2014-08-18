
//
//  UnzipManager.m
//  protoview
//
//  Created by Madison, Jon on 8/14/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "UnzipManager.h"
#import "Util.h"

@implementation UnzipManager
-(id)init
{
  return [super init];
}

-(void)downloadAndUnzipFileNamed:(NSString*)fileName intoDirectory:(NSString*) destinationDirectory fromURL:(NSURL *)url withCompletion:(void(^)(NSURL*,NSError*))completion
{
  NSError* error = nil;
  NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
  [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
  
  NSFileManager* fileManager = [NSFileManager defaultManager];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ProtoviewDownloadingFiles" object:nil];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [Util downloadFileNamed:fileName FromUrl:url withCompletion:^(NSURL *downloadedZip, NSError *downloadError) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(downloadError) {
      [[NSNotificationCenter defaultCenter] postNotificationName:@"ProtoviewUnzippingFilesError" object:nil];
      return completion(nil,error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProtoviewUnzippingFiles" object:nil];
    NSData* data = [NSData dataWithContentsOfURL:downloadedZip];
        
    ZZArchive* archive = [ZZArchive archiveWithData:data];
    NSError* err = nil;
    
    //cleanup
    NSURL* destinationDirectoryURL = [NSURL URLWithString:destinationDirectory];
    
    for (ZZArchiveEntry* entry in archive.entries)
    {
      NSURL* targetPath = [destinationDirectoryURL URLByAppendingPathComponent:entry.fileName];
      if (entry.fileMode & S_IFDIR) {
        // check if directory bit is set
        [fileManager createDirectoryAtPath:[targetPath absoluteString]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&err];
        if(err) {
          NSLog(@"error creating a dir solo: %@",err);
        }
      }
      else
      {
        // Some archives don't have a separate entry for each directory and just
        // include the directory's name in the filename. Make sure that directory exists
        // before writing a file into it.
        [fileManager createDirectoryAtPath:[[targetPath URLByDeletingLastPathComponent]absoluteString]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&err];
        
        if(err)
        {
          NSLog(@"error creating dir: %@",[err localizedDescription]);
        } else {
          NSLog(@"unzipped directory %@",targetPath);
        }
        
        [[entry newDataWithError:&err] writeToFile:[targetPath absoluteString]
                                       atomically:NO];
        if(err) {
          NSLog(@"error copying zip entry: %@",[err localizedDescription]);
        } else {
          NSLog(@"unzipped file %@",targetPath);
        }
      }
    }
    [[NSFileManager defaultManager] removeItemAtURL:downloadedZip error:&err];
    if(err) {
      NSLog(@"error removing downloaded file: %@",[err localizedDescription]);
    }
    // We are now done with the archive
    archive = nil;
    completion(directoryURL,nil);
  }];
}

@end
