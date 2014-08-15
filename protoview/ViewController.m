//
//  ViewController.m
//  protoview
//
//  Created by Madison, Jon on 8/13/14.
//  Copyright (c) 2014 nordlab. All rights reserved.
//

#import "ViewController.h"
#import "WebServerManager.h"
#import <MBProgressHUD.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;
@end

@implementation ViewController
{
@private WebServerManager* _webserverManager;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  _webserverManager = [WebServerManager instance];
  UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(closeMe)];
  [longPress setNumberOfTouchesRequired:3];
  [_mainWebView addGestureRecognizer:longPress];
  [_webserverManager startWebServerWithRoot:@"/prototypes" andPort:9999];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  NSLog(@"selected prototype %@",_currentPrototype);
  NSString* requestedUrl = [NSString stringWithFormat:@"http://127.0.0.1:9999/%@/index.html",_currentPrototype];
  NSLog(@"requesting URL %@",requestedUrl);
  
  NSURL *url = [NSURL URLWithString:requestedUrl];
  NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
  
  MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"Loading";

  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [hud hide:YES];
      [_mainWebView loadRequest:urlRequest];
    });
  });
}

- (void)closeMe {
  if (![self.presentedViewController isBeingDismissed]) {
    [self dismissViewControllerAnimated:YES completion:^{
      [_webserverManager stopWebServer];
    }];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if(motion==UIEventSubtypeMotionShake)
  {
    [self closeMe];
  }
}
@end
