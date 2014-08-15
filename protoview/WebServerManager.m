//
//  WebServerManager.m
//  protoview
//
//  Created by Madison, Jon on 8/14/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "WebServerManager.h"

static WebServerManager* sharedObject;

@implementation WebServerManager
+ (WebServerManager*)instance
{
  if (sharedObject == nil) {
    sharedObject = [[self allocWithZone:NULL] init];
  }
  return sharedObject;
}

-(GCDWebServer*)webserver
{
  if(!_webserver) {
    _webserver = [[GCDWebServer alloc]init];
  }
  return _webserver;
}
-(void)startWebServerWithRoot:(NSString *)webRoot andPort:(NSUInteger)portNumber
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString* prototypesPath = [NSString stringWithFormat:@"%@%@",documentsDirectory,webRoot];
  
  [[self webserver] addGETHandlerForBasePath:@"/" directoryPath:prototypesPath indexFilename:@"index.html" cacheAge:WEBSERVER_CACHE_AGE allowRangeRequests:YES];
  [[self webserver] startWithPort:portNumber bonjourName:WEBSERVER_BONJOUR_NAME];
  NSLog(@"serving documents from %@",prototypesPath);
}

-(void)stopWebServer {
  if([[self webserver] isRunning]){
    [_webserver stop];
  }
}
@end
