//
//  WebServerManager.h
//  protoview
//
//  Created by Madison, Jon on 8/14/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDWebServer.h>

@interface WebServerManager : NSObject
@property (nonatomic,retain) GCDWebServer* webserver;
+ (WebServerManager*)instance;
-(void)startWebServerWithRoot:(NSString *)webRoot andPort:(NSUInteger)portNumber;
-(void)stopWebServer;
@end
