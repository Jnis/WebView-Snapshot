//
//
//  Created by Yanis Plumit on 11/30/12.
//  Copyright (c) 2016. All rights reserved.
//

#import "UIKit/UIKit.h"
#import <WebKit/WebKit.h>
#import <Foundation/Foundation.h>

@interface UIWebView (Size)
-(CGSize)maWebPageSize;
-(CGFloat)maWebPageScale;
@end

//@interface WKWebView(SynchronousEvaluateJavaScript)
//- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
//@end

@interface WKWebView (Size)
-(void)maWebPageSize:(void (^)(CGSize size))completionHandler;
-(CGSize)maWebPageSize_fast;
-(CGFloat)maWebPageScale;
@end
