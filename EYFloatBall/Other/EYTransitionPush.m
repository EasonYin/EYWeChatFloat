//
//  EYTransitionPush.m
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import "EYTransitionPush.h"
#import "EYFloatConfigure.h"
#import "EYFloatManager.h"

@interface EYTransitionPush () <CAAnimationDelegate>
@property(nonatomic, strong) id <UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic, strong) UIView *coverView;
@end

@implementation EYTransitionPush
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *contView = [transitionContext containerView];
    [contView addSubview:fromVC.view];
    [contView addSubview:toVC.view];
    
    CGRect floatBallRect = [EYFloatManager shared].floatBall.frame;
    [fromVC.view addSubview:self.coverView];
    UIBezierPath *maskStartBP = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(floatBallRect.origin.x, floatBallRect.origin.y, floatBallRect.size.width, floatBallRect.size.height) cornerRadius:floatBallRect.size.height / 2];
    UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) cornerRadius:floatBallRect.size.width / 2];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskFinalBP.CGPath;
    toVC.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id) (maskStartBP.CGPath);
    maskLayerAnimation.toValue = (__bridge id) ((maskFinalBP.CGPath));
    maskLayerAnimation.duration = kAuration;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    
    [UIView animateWithDuration:kAuration animations:^{
        [[EYFloatManager shared].floatViewArray enumerateObjectsUsingBlock:^(EYFloatBall*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == [EYFloatManager shared].floatBall) {
                obj.alpha = 0;
            }else{
                obj.alpha = 1.0f;
            }
        }];
    }];
}

#pragma mark - CABasicAnimation的Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.transitionContext completeTransition:YES];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
    [self.coverView removeFromSuperview];
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.5;
    };
    return _coverView;
}
@end
