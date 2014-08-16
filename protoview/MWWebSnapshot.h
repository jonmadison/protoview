//
//  MWWebSnapshot.h
//
//  Created by Jim McGowan on 08/09/2010.
//  Copyright 2010 Jim McGowan. All rights reserved.
//
//  This code is made available under the BSD license.  Please see the accompanying license.txt file
//	or view the license online at http://www.malkinware.com/developer/License.txt
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface MWWebSnapshot : NSObject 
{
	void (^completionBlock)(NSImage *image);
	WebView *webView;
}

+ (void)takeSnapshotOfWebPageAtURL:(NSURL *)url completionBlock:(void (^)(NSImage *))block;


@end
