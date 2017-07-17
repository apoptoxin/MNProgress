//
//  MNCircleProgressView.h
//  MNProgress
//
//  Created by apoptoxin on 17/7/15.
//  Copyright © 2017年 micronil. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "MNProgressCommonDefines.h"

@interface MNCircleProgressView : UIView
@property (nonatomic, assign, getter=isGradient) BOOL gradient;
//if gradient equals NO, use fillColor,otherwise use fillColors. default color is white
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, copy) NSArray<UIColor*> *fillColors;

- (void)startAnimationWithCountDown:(CGFloat)countDown completion:(MNProgressCompletionBlock)completion;
- (void)startAnimationWithProgress:(NSProgress *)progress completion:(MNProgressCompletionBlock)completion;
@end
