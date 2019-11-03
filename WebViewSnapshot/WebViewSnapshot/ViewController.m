//
//  ViewController.m
//  WebViewSnapshot
//
//  Created by Yanis Plumit on 05/10/2019.
//  Copyright © 2019 Yanis Plumit. All rights reserved.
//

#import "ViewController.h"
#import "INWebViewHelper.h"

@interface ViewController () <INWebViewHelperDelegate>
@property(nonatomic,assign) UIBackgroundTaskIdentifier bgTask;
@property(nonatomic,strong) INWebViewHelper *webViewHelper;

@property (weak, nonatomic) IBOutlet UIView *webviewContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrrenshotsScrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webViewHelper = [INWebViewHelper new];
    self.webViewHelper.delegate = self;
    
    self.bgTask = UIBackgroundTaskInvalid;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)reloadWebView {
    [self.webViewHelper cleanWebViewMemory];
    [self.webViewHelper createWebView];
    [self.webviewContainerView addSubview:self.webViewHelper.webView];
    self.webViewHelper.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webViewHelper.webView.frame = self.webviewContainerView.bounds;
    [self.webViewHelper loadUrl:[NSURL URLWithString:@"https://www.apple.com/"]];
}

- (void)doSnapshot {
    NSLog(@"START!");
    while (self.scrrenshotsScrollView.subviews.count > 0) {
        [self.scrrenshotsScrollView.subviews.firstObject removeFromSuperview];
    }
    
    if (self.webViewHelper.webView == nil) {
        NSLog(@"Please, select webview");
    } else {
        self.scrrenshotsScrollView.backgroundColor = [UIColor yellowColor];
        [self.webViewHelper webPageSize:^(CGSize webPageSize) {
            NSMutableArray<NSValue *> *rectsToLoadArray = [NSMutableArray array];
            CGFloat squareSize = 1024;
            for(int iy = 0; iy <= webPageSize.height/squareSize; iy++){
                for(int ix = 0; ix <= webPageSize.width/squareSize; ix++){
                    CGRect rect = CGRectMake(squareSize*ix, squareSize*iy
                                             , MIN(squareSize, webPageSize.width - squareSize*ix)
                                             , MIN(squareSize, webPageSize.height - squareSize*iy));
                    if(rect.size.width > 0 && rect.size.height > 0){
                        [rectsToLoadArray addObject:[NSValue valueWithCGRect:rect]];
                    }
                }
            }
            [self saveRects:rectsToLoadArray webPageSize:webPageSize];
        }];
    }
}

- (void)saveRects:(NSArray<NSValue *> *)rectsToLoadArray webPageSize:(CGSize)webPageSize {
    if (rectsToLoadArray.count > 0) {
        NSMutableArray<NSValue *> *newArray = [NSMutableArray arrayWithArray:rectsToLoadArray];
        NSValue *rectValue = newArray.firstObject;
        [newArray removeObjectAtIndex:0];
        [self.webViewHelper imageFromWebViewRect:rectValue.CGRectValue loadedWebViewSize:webPageSize completionHandler:^(UIImage *image) {
            if (image != nil) {
                NSLog(@"SUCCESS! left: %lu", (unsigned long)rectsToLoadArray.count);
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.backgroundColor = [UIColor redColor];
                imageView.frame = CGRectMake(0,
                                             CGRectGetMaxY(self.scrrenshotsScrollView.subviews.lastObject.frame) + 3,
                                             self.scrrenshotsScrollView.bounds.size.width,
                                             self.scrrenshotsScrollView.bounds.size.width / image.size.width * image.size.height);
                [self.scrrenshotsScrollView addSubview:imageView];
                [self saveRects:newArray webPageSize:webPageSize];
                self.scrrenshotsScrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.scrrenshotsScrollView.subviews.lastObject.frame));
            } else {
                NSLog(@"FAILED TO GET IMAGE :-(");
                [self finish:[UIColor redColor]];
            }
        }];
    } else {
        [self finish:[UIColor greenColor]];
    }
}

- (void)finish:(UIColor*)color {
    self.scrrenshotsScrollView.backgroundColor = color;
    if(_bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Actions

- (IBAction)selectUIWebviewAction:(id)sender {
    self.webViewHelper.useWKWebView = false;
    [self reloadWebView];
}

- (IBAction)selectWKWebViewAction:(id)sender {
    self.webViewHelper.useWKWebView = true;
    [self reloadWebView];
}

- (IBAction)doSnapshotNowAction:(id)sender {
    [self doSnapshot];
}

- (void)appWillResignActiveNotification {
    if (self.webViewHelper.webView) {
        if(UIBackgroundTaskInvalid == self.bgTask){ //initiate sending if it need
            self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                NSLog(@"Oops! bgTask expired.");
                [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
                self.bgTask = UIBackgroundTaskInvalid;
            }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doSnapshot];
        });
    }
}

#pragma mark - INWebViewHelperDelegate

- (void)webViewHelperDidStartLoad:(INWebViewHelper *)webView {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webViewHelperDidFinishLoad:(INWebViewHelper *)webView {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webViewHelper:(INWebViewHelper *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
}

@end
