//
//  UnzipManager.h
//  protoview
//
//  Created by Madison, Jon on 8/14/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZZArchive.h>
#import <ZZArchiveEntry.h>

@interface UnzipManager : NSObject
@property (nonatomic,retain) ZZArchive* zipArchive;

-(void)downloadAndUnzipFileNamed:(NSString*)fileName intoDirectory:(NSString*) destinationDirectory fromURL:(NSURL *)url withCompletion:(void(^)(NSURL*,NSError*))completion;
@end
