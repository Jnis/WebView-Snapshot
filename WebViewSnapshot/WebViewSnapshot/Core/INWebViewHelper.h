//
//  INWebViewHelper.h
//  widgetNotes
//
//  Created by Yanis Plumit on 16/09/2019.
//  Copyright © 2019 jnis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INWebViewHelper;

@protocol INWebViewHelperDelegate
- (void)webViewHelperDidStartLoad:(INWebViewHelper *)webView;
- (void)webViewHelperDidFinishLoad:(INWebViewHelper *)webView;
- (void)webViewHelper:(INWebViewHelper *)webView didFailLoadWithError:(NSError *)error;
@end

@interface INWebViewHelper: NSObject
@property(nonatomic,assign) BOOL useWKWebView;
@property(nonatomic,assign) id<INWebViewHelperDelegate> delegate;
-(UIView*)webView;
-(void)cleanWebViewMemory;
-(void)createWebView;
-(void)loadUrl:(NSURL*)url;
-(void)stopLoading;
-(void)webPageSize:(void (^)(CGSize size))completionHandler;
-(void)imageFromWebViewRect:(CGRect)imageRect loadedWebViewSize:(CGSize)loadedWebViewSize completionHandler:(void(^)(UIImage *image))completionHandler;
@end
