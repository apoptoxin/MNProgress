//
//  MNCircleProgressView.m
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

#import "MNCircleProgressView.h"

#define kRadiusProportion 0.8

@interface MNCircleProgressView()<CAAnimationDelegate>
@property (nonatomic, strong) CAShapeLayer *frontCircleLayer;
@property (nonatomic, strong) NSProgress *curProgress;
@property (nonatomic, copy) MNProgressCompletionBlock completion;
@end

@implementation MNCircleProgressView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}

- (void)startAnimationWithCountDown:(CGFloat)countDown completion:(MNProgressCompletionBlock)completion{
    self.completion = completion;
    [self _reloadFrontCircleLayerWithStrokeEnd:1.0f];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.byValue = @(0.5f);
    animation.duration = countDown;
    animation.delegate = self;
    //apply animation to layer
    [self.frontCircleLayer addAnimation:animation forKey:@"strokeEnd"];
}

- (void)startAnimationWithProgress:(NSProgress *)progress completion:(MNProgressCompletionBlock)completion{
    self.completion = completion;
    self.curProgress = progress;
    [self _reloadFrontCircleLayerWithStrokeEnd:0.0f];
    [self.curProgress addObserver:self forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat new = [change[@"new"] doubleValue];
    self.frontCircleLayer.strokeEnd = new < 0.0f ? 0.0f : (new > 1.0f ? 1.0f :new);
    if (new >= 1.0f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.completion) {
                self.completion(true);
            }
        });
    }
}
#pragma mark - Private Method
- (void)_reloadFrontCircleLayerWithStrokeEnd:(CGFloat)strokeEnd {
    [self.frontCircleLayer removeAnimationForKey:@"strokeEnd"];
    [self.frontCircleLayer removeFromSuperlayer];
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) * kRadiusProportion * 0.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:radius startAngle:- 0.5 * M_PI endAngle:1.5 * M_PI clockwise:YES];
    _frontCircleLayer = [CAShapeLayer layer];
    _frontCircleLayer.fillColor = [UIColor clearColor].CGColor;
    _frontCircleLayer.strokeColor = [self.fillColor isKindOfClass:[UIColor class]] ? self.fillColor.CGColor : [UIColor whiteColor].CGColor;
    _frontCircleLayer.path = path.CGPath;
    _frontCircleLayer.strokeStart = 0.0f;
    _frontCircleLayer.strokeEnd = MIN(1.0f, MAX(0.0f, strokeEnd));
    _frontCircleLayer.lineWidth = 2.0f;
    [self.layer addSublayer:self.frontCircleLayer];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {
    if ([anim.toValue isEqual:@(1.0)]) {
        if (self.completion != nil) {
            self.completion(flag);
        }
    }
}
@end
