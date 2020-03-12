//
//  INWebViewHelper.m
//  widgetNotes
//
//  Created by Yanis Plumit on 16/09/2019.
//  Copyright © 2019 jnis. All rights reserved.
//

#import "INWebViewHelper.h"
#import "UIWebView+Size.h"
#import "UIView+Shapshot.h"

//min iOS 11.0
//#define WK_CHOICE_CONDITION (@available(iOS 13, *))
#define WK_CHOICE_CONDITION (self.useWKWebView)

@interface INWebViewHelper() <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property(nonatomic,strong) UIWebView *uiwebView;
@property(nonatomic,strong) UIView * screenshotView;
@property(nonatomic,strong) WKWebView *wkwebView;
@end

@implementation INWebViewHelper

-(void)dealloc{
    self.uiwebView.delegate = nil;
    self.wkwebView.UIDelegate = nil;
    self.wkwebView.navigationDelegate = nil;
}

-(UIView*)webView {
    if WK_CHOICE_CONDITION {
        return self.wkwebView;
    } else {
        return self.uiwebView;
    }
}

-(void)cleanWebViewMemory{
    [self.webView removeFromSuperview];
    self.uiwebView.delegate = nil;
    self.wkwebView.UIDelegate = nil;
    self.wkwebView.navigationDelegate = nil;
    self.uiwebView = nil;
    self.wkwebView = nil;
    self.screenshotView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

-(void)createWebView {
    if WK_CHOICE_CONDITION {
        NSString *jScript = @"var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; var head = document.getElementsByTagName('head')[0]; head.appendChild(meta);";
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = wkUController;
        
        self.wkwebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkWebConfig];
        self.wkwebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.wkwebView.navigationDelegate = self;
        self.wkwebView.UIDelegate = self;
    } else {
        self.uiwebView = [UIWebView new];
        if (@available(iOS 11.0, *)) {
            self.uiwebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.uiwebView.scalesPageToFit = YES;
        self.uiwebView.delegate = self;
    }
}

-(void)loadUrl:(NSURL*)url {
//#ifndef IOS_EXTANTION
//    [[UIApplication sharedApplication].keyWindow addSubview:self.webView];
//    self.webView.hidden = true;
//#endif
    if WK_CHOICE_CONDITION {
        [self.wkwebView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
        self.wkwebView.contentScaleFactor = 1;
        self.wkwebView.scrollView.contentScaleFactor = 1;
        self.wkwebView.scrollView.zoomScale = 1;
    } else {
        [self.uiwebView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    }
}

-(void)stopLoading {
    if WK_CHOICE_CONDITION {
        [self.wkwebView stopLoading];
    } else {
        [self.uiwebView stopLoading];
    }
}

-(void)webPageSize:(void (^)(CGSize size))completionHandler {
    if WK_CHOICE_CONDITION {
        return [self.wkwebView maWebPageSize:completionHandler];
    } else {
        completionHandler([self.uiwebView maWebPageSize]);
    }
}

-(void)imageFromWebViewRect:(CGRect)imageRect loadedWebViewSize:(CGSize)loadedWebViewSize completionHandler:(void(^)(UIImage *image))completionHandler{
    if (nil == self.screenshotView) {
        self.screenshotView = [UIView new];
        self.webView.hidden = false;
        [self.screenshotView addSubview:self.webView];
        //#ifdef DEBUG
        //        UIView* lineView = [UIView new];
        //        lineView.backgroundColor = [UIColor redColor];
        //        [self.screenshotView addSubview:lineView];
        //        lineView.frame = CGRectMake(0, 0, 100, 1);
        //#endif
    }
    
    CGRect screenshotRect = CGRectMake(0, 0
                                       , MIN(imageRect.size.width, loadedWebViewSize.width - imageRect.origin.x)
                                       , MIN(imageRect.size.height, loadedWebViewSize.height - imageRect.origin.y));
    
    CGFloat squareSize = MAX(1024, MAX(imageRect.size.width, imageRect.size.height)); //Usualy it 1024
    CGSize webViewVisibleSize = CGSizeMake(  MIN(squareSize * 3, loadedWebViewSize.width)
                                           , MIN(squareSize * 3, loadedWebViewSize.height));
    CGPoint webViewContentOffset = CGPointMake(  MAX(0, MIN(loadedWebViewSize.width - webViewVisibleSize.width, imageRect.origin.x - squareSize))
                                               , MAX(0, MIN(loadedWebViewSize.height - webViewVisibleSize.height, imageRect.origin.y - squareSize)));
    CGPoint webViewOffset = CGPointMake( webViewContentOffset.x - imageRect.origin.x
                                        , webViewContentOffset.y - imageRect.origin.y);
//#ifndef IOS_EXTANTION
//    [[INDiagnostic sharedInstance] addLog:[NSString stringWithFormat:@"L %.0f %.0f /W %.0f %.0f", loadedWebViewSize.width, loadedWebViewSize.height, webViewVisibleSize.width, webViewVisibleSize.height]];
//#endif
    self.screenshotView.frame = screenshotRect;
    if WK_CHOICE_CONDITION {
        [self.wkwebView.scrollView setContentOffset:CGPointMake(webViewContentOffset.x, webViewContentOffset.y) animated:NO];
        self.wkwebView.frame = CGRectMake( webViewOffset.x, webViewOffset.y, webViewVisibleSize.width, webViewVisibleSize.height);
        
        //TODO: !!!
        __block void(^blockCompletionHandler)(UIImage *image) = completionHandler;
        
        WKSnapshotConfiguration *configuration = [WKSnapshotConfiguration new];
        if (@available(iOS 13.0, *)) {
            configuration.afterScreenUpdates = NO;
        }
        configuration.rect = CGRectMake(-webViewOffset.x, -webViewOffset.y, screenshotRect.size.width, screenshotRect.size.height);
        [self.wkwebView takeSnapshotWithConfiguration:configuration completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
            NSLog(@"wkwebView takeSnapshotWithConfiguration. Error = %@", error);
            if (blockCompletionHandler != nil) {
                completionHandler(snapshotImage);
                blockCompletionHandler = nil;
            }
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (blockCompletionHandler != nil) {
                NSLog(@"wkwebView takeSnapshotWithConfiguration. Error: completionHandler 3 sec timeout hook =(");
                completionHandler(nil);
                blockCompletionHandler = nil;
            }
        });
    } else {
        [self.uiwebView.scrollView setContentOffset:CGPointMake(webViewContentOffset.x, webViewContentOffset.y) animated:NO];
        self.uiwebView.frame = CGRectMake( webViewOffset.x, webViewOffset.y, webViewVisibleSize.width, webViewVisibleSize.height);
        
        //big page: http://barnikov.ru/vstuplenie-v-nasledstvo-dokumenty-dlya-oformleniya-nasledstva
        UIImage *image = [self.screenshotView maShapshot];
        NSLog(@"%s rect=%@ %@", __PRETTY_FUNCTION__, NSStringFromCGRect(imageRect), image);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionHandler(image);
        });
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.delegate webViewHelperDidStartLoad:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.delegate webViewHelperDidFinishLoad:self];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.delegate webViewHelper:self didFailLoadWithError:error];
}

#pragma mark - WKNavigationDelegate, WKUIDelegate

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s = %@", __PRETTY_FUNCTION__, error);
    [self webView:webView didFailNavigation:navigation withError:error]; //TODO: ?
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.delegate webViewHelperDidStartLoad:self];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.wkwebView.contentScaleFactor = 1;
    self.wkwebView.scrollView.contentScaleFactor = 1;
    self.wkwebView.scrollView.zoomScale = 1;
    [self.delegate webViewHelperDidFinishLoad:self];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.delegate webViewHelper:self didFailLoadWithError:error];
}

@end
