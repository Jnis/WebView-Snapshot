//
//  UIView+Shapshot.m
//
//
//  Created by  on 7/24/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "UIView+Shapshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shapshot)

#pragma mark -

- (UIImage *)maShapshot {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
