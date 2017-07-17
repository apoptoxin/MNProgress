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
#define kCircleLineWidth 3.0f

@interface MNCircleProgressView()<CAAnimationDelegate>
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAGradientLayer *leftCircleLayer;
@property (nonatomic, strong) CAGradientLayer *rightCircleLayer;
@property (nonatomic, strong) CALayer *circleLayer;
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
    [self _reloadCircleLayerWithStrokeEnd:1.0f];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.byValue = @(0.5f);
    animation.duration = countDown;
    animation.delegate = self;
    //apply animation to layer
    [self.maskLayer addAnimation:animation forKey:@"strokeEnd"];
}

- (void)startAnimationWithProgress:(NSProgress *)progress completion:(MNProgressCompletionBlock)completion{
    [self.curProgress removeObserver:self forKeyPath:@"fractionCompleted"];
    self.completion = completion;
    self.curProgress = progress;
    [self _reloadCircleLayerWithStrokeEnd:0.0f];
    [self.curProgress addObserver:self forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat new = [change[@"new"] doubleValue];
    self.maskLayer.strokeEnd = new < 0.0f ? 0.0f : (new > 1.0f ? 1.0f :new);
    if (new >= 1.0f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.completion) {
                MNProgressCompletionBlock completion = [self.completion copy];
                self.completion = nil;
                completion(true);
            }
        });
    }
}

- (void)setGradient:(BOOL)gradient {
    _gradient = gradient;
    [self _reloadCircleSubLayer];
}

- (void)setFillColors:(NSArray<UIColor *> *)fillColors {
    _fillColors = [fillColors copy];
    [self _reloadCircleSubLayer];
}
#pragma mark - Private Method

- (void)_reloadCircleLayerWithStrokeEnd:(CGFloat)strokeEnd {
    [self.maskLayer removeAnimationForKey:@"strokeEnd"];
    [self.maskLayer removeFromSuperlayer];
    [self.circleLayer removeFromSuperlayer];
    _circleLayer = [CALayer layer];
    _circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) * kRadiusProportion * 0.5;
    _circleLayer.frame = CGRectMake(self.frame.size.width * 0.5 - radius, self.frame.size.height * 0.5 - radius, radius * 2, radius * 2);
    [self _reloadLeftCircleLayerWithRect:self.circleLayer.frame superLayer:self.circleLayer];
    [self _reloadRightCircleLayerWithRect:self.circleLayer.frame superLayer:self.circleLayer];
    [self.maskLayer removeAnimationForKey:@"strokeEnd"];
    [self.maskLayer removeFromSuperlayer];
    _maskLayer = [self _reloadMaskLayerWithStrokeEnd:strokeEnd superLayer:self.circleLayer];
    [self.layer addSublayer:self.circleLayer];
}

- (void)_reloadCircleSubLayer {
    CALayer *layer = self.circleLayer;
    [self _reloadLeftCircleLayerWithRect:layer.frame superLayer:layer];
    [self _reloadRightCircleLayerWithRect:layer.frame superLayer:layer];
}

- (CAShapeLayer *)_reloadMaskLayerWithStrokeEnd:(CGFloat)strokeEnd superLayer:(CALayer*)superLayer{
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) * kRadiusProportion * 0.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(superLayer.frame.size.width * 0.5, superLayer.frame.size.height * 0.5) radius:radius - kCircleLineWidth * 0.5 startAngle:- 0.5 * M_PI endAngle:1.5 * M_PI clockwise:YES];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.strokeColor = [self.fillColor isKindOfClass:[UIColor class]] ? self.fillColor.CGColor : [UIColor whiteColor].CGColor;
    maskLayer.path = path.CGPath;
    maskLayer.strokeStart = 0.0f;
    maskLayer.strokeEnd = MIN(1.0f, MAX(0.0f, strokeEnd));
    maskLayer.lineWidth = kCircleLineWidth;
    superLayer.mask = maskLayer;
    return maskLayer;
}

- (void)_reloadLeftCircleLayerWithRect:(CGRect)frame superLayer:(CALayer*)superLayer {
    [self.leftCircleLayer removeFromSuperlayer];
    _leftCircleLayer = [CAGradientLayer layer];
    _leftCircleLayer.frame = CGRectMake(0, 0, frame.size.width * 0.5, frame.size.height);
    _leftCircleLayer.startPoint = CGPointMake(0.0, 1.0);
    _leftCircleLayer.endPoint = CGPointMake(0.0, 0.0);
    NSArray *colorAry = [self _fixFillColors:self.fillColors];
    if (self.isGradient) {
        NSMutableArray *curColorAry = [NSMutableArray array];
        NSUInteger start = colorAry.count / 2;
        NSUInteger end = colorAry.count;
        [colorAry enumerateObjectsUsingBlock:^(UIColor*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= start && idx < end) {
                [curColorAry addObject:(__bridge id _Nonnull)obj.CGColor];
            }
        }];
        if (curColorAry.count == 1) {
            [curColorAry addObject:[curColorAry lastObject]];
        }
        _leftCircleLayer.colors = curColorAry;
        if (curColorAry.count > 2) {
            CGFloat step = 1.0 / (curColorAry.count - 1);
            NSMutableArray *positions = [NSMutableArray array];
            for (int i = 0; i < curColorAry.count; i++) {
                [positions addObject:[NSNumber numberWithFloat:step * i]];
                _leftCircleLayer.locations = positions;
            }
        }
    } else {
        CGColorRef color = [self.fillColor isKindOfClass:[UIColor class]] ? self.fillColor.CGColor : [UIColor whiteColor].CGColor;
        _leftCircleLayer.colors = [NSArray arrayWithObjects:(__bridge id _Nonnull)(color),(__bridge id _Nonnull)(color), nil];
    }
    [superLayer addSublayer:self.leftCircleLayer];
}

- (void)_reloadRightCircleLayerWithRect:(CGRect)frame superLayer:(CALayer*)superLayer {
    [self.rightCircleLayer removeFromSuperlayer];
    _rightCircleLayer = [CAGradientLayer layer];
    _rightCircleLayer.frame = CGRectMake(frame.size.width * 0.5, 0, frame.size.width * 0.5, frame.size.height);
    _rightCircleLayer.startPoint = CGPointMake(0.0, 0.0);
    _rightCircleLayer.endPoint = CGPointMake(0.0, 1.0);
    NSArray *colorAry = [self _fixFillColors:self.fillColors];
    if (self.isGradient) {
        NSMutableArray *curColorAry = [NSMutableArray array];
        NSUInteger start = 0;
        NSUInteger end = colorAry.count / 2;
        [colorAry enumerateObjectsUsingBlock:^(UIColor*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= start && idx < end) {
                [curColorAry addObject:(__bridge id _Nonnull)obj.CGColor];
            }
        }];
        if (curColorAry.count == 1) {
            [curColorAry addObject:[curColorAry lastObject]];
        }
        _rightCircleLayer.colors = curColorAry;
        if (curColorAry.count > 2) {
            CGFloat step = 1.0 / (curColorAry.count - 1);
            NSMutableArray *positions = [NSMutableArray array];
            for (int i = 0; i < curColorAry.count; i++) {
                [positions addObject:[NSNumber numberWithFloat:step * i]];
                _rightCircleLayer.locations = positions;
            }
        }
    } else {
        CGColorRef color = [self.fillColor isKindOfClass:[UIColor class]] ? self.fillColor.CGColor : [UIColor whiteColor].CGColor;
        
        _rightCircleLayer.colors = [NSArray arrayWithObjects:(__bridge id _Nonnull)(color),(__bridge id _Nonnull)(color), nil];
    }
    [superLayer addSublayer:self.rightCircleLayer];
}

- (NSArray *)_fixFillColors:(NSArray *)fillColors {
    NSMutableArray *array = [NSMutableArray array];
    [self.fillColors enumerateObjectsUsingBlock:^(UIColor *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIColor class]]) {
            [array addObject:obj];
        }
    }];
    if (array.count <= 0) {
        [array addObject:[UIColor whiteColor]];
        [array addObject:[UIColor whiteColor]];
    }
    NSUInteger index = array.count / 2;
    UIColor *color = [array objectAtIndex:index];
    if (array.count % 2 == 1) {
        //奇数个
        [array insertObject:color atIndex:index];
    } else {
        [array insertObject:color atIndex:index];
        [array insertObject:color atIndex:index];
    }
    return [array copy];
}
#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {
    if ([anim.toValue isEqual:@(1.0)]) {
        if (self.completion) {
            MNProgressCompletionBlock completion = [self.completion copy];
            self.completion = nil;
            completion(flag);
        }
    }
}
@end
