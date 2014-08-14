//
//  Util.h
//  protoview
//
//  Created by Madison, Jon on 8/13/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject
+ (void)createDirectory:(NSString*)directoryPath;
+ (void)copyPrototypeHTMLFromPath:(NSString*)fromPath toPath:(NSString*)toPath;
@end
