//
//
//  Created by Yanis Plumit on 11/30/12.
//  Copyright (c) 2016. All rights reserved.
//

#import "UIWebView+Size.h"

@implementation UIWebView (Size)

-(CGSize)maWebPageSize{
    CGSize doc = CGSizeMake([self stringByEvaluatingJavaScriptFromString:@"document.width;"].floatValue
                            , [self stringByEvaluatingJavaScriptFromString:@"document.height;"].floatValue );
    
    CGSize scroll = CGSizeMake([self stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"].floatValue
                               , [self stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"].floatValue );
    
    CGSize contentSize = CGSizeMake(MAX(doc.width, scroll.width),
                                    MAX(doc.height, scroll.height) );
    
    return contentSize;
}

-(CGFloat)maWebPageScale{
    return self.scrollView.contentSize.width / [self maWebPageSize].width;
}

@end


//-----


//@implementation WKWebView(SynchronousEvaluateJavaScript)
//
//- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
//{
//    __block NSString *resultString = nil;
//    __block BOOL finished = NO;
//    
//    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
//        if (error == nil) {
//            if (result != nil) {
//                resultString = [NSString stringWithFormat:@"%@", result];
//            }
//        } else {
//            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
//        }
//        finished = YES;
//    }];
//    
//    while (!finished)
//    {
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
//    
//    return resultString;
//}
//@end


//-----


@implementation WKWebView (Size)

-(void)maWebPageSize:(void (^)(CGSize size))completionHandler {
    [self evaluateJavaScript:@"document.body.scrollWidth;" completionHandler:^(NSNumber* _Nullable scroll_width, NSError * _Nullable error) {
        [self evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(NSNumber* _Nullable scroll_height, NSError * _Nullable error) {
            CGSize contentSize = CGSizeMake(scroll_width.floatValue, scroll_height.floatValue);
//#ifndef IOS_EXTANTION
//            [[INDiagnostic sharedInstance] addLog:[NSString stringWithFormat:@"http %@ %@ |Scr %.0f %.0f |s %.3f %.3f", scroll_width, scroll_height, self.scrollView.contentSize.width, self.scrollView.contentSize.height, self.scrollView.zoomScale, self.contentScaleFactor]];
//#endif
            completionHandler(contentSize);
        }];
    }];
    
//    CGSize doc = CGSizeMake([self stringByEvaluatingJavaScriptFromString:@"document.width;"].floatValue
//                            , [self stringByEvaluatingJavaScriptFromString:@"document.height;"].floatValue );
//
//    CGSize scroll = CGSizeMake([self stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"].floatValue
//                               , [self stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"].floatValue );
//
//    CGSize contentSize = CGSizeMake(MAX(doc.width, scroll.width),
//                                    MAX(doc.height, scroll.height) );
    
//    return contentSize;
}

-(CGSize)maWebPageSize_fast{
    return self.scrollView.zoomScale > 0 ? CGSizeMake(self.scrollView.contentSize.width / self.scrollView.zoomScale , self.scrollView.contentSize.height / self.scrollView.zoomScale) : CGSizeMake(0,0);
}

-(CGFloat)maWebPageScale{
//    return self.scrollView.contentSize.width / [self maWebPageSize].width;
//    NSLog(@"%f, %@, %@", self.scrollView.zoomScale, NSStringFromCGSize(self.scrollView.contentSize), NSStringFromCGSize(self.scrollView.bounds.size));
    
    return self.scrollView.zoomScale;
}

@end
