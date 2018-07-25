//
//  EYFloatManager.m
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import "EYFloatManager.h"
#import "EYFloatConfigure.h"
#import "EYFloatBall.h"
#import "EYFloatAreaView.h"
#import "EYTransitionPush.h"
#import "EYTransitionPop.h"
#import "NSObject+eyvc.h"

@interface EYFloatManager () <EYFloatBallDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, strong) EYFloatAreaView *floatArea;
@property(nonatomic, strong) UIViewController *tempFloatViewController;
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;
@property(nonatomic, strong) CADisplayLink *link;
@property(nonatomic, assign) BOOL showFloatBall;
@property(nonatomic, assign) BOOL havePossible;//是否手势完成 UIGestureRecognizerStatePossible 状态会触发多次，加状态防止添加重复对象
@property(nonatomic, assign) BOOL haveFloatView;
@property(nonatomic, strong) NSMutableArray<NSString *> *floatVcClass;

@end

@implementation EYFloatManager

#pragma mark -

+ (instancetype)shared {
    static EYFloatManager *floatManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        floatManager = [[super allocWithZone:nil] init];
        floatManager.floatVcClass = [NSMutableArray array];
        floatManager.MaxFloatViewArrayCount = 3;//默认浮窗个数
        //设置边缘侧滑代理
        [floatManager ey_currentNavigationController].interactivePopGestureRecognizer.delegate = floatManager;
        [floatManager ey_currentNavigationController].delegate = floatManager;
    });
    return floatManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [EYFloatManager shared];
}

- (id)copyWithZone:(NSZone *)zone {
    return [EYFloatManager shared];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [EYFloatManager shared];
}

#pragma mark -

+ (void)addFloatVcs:(NSArray<NSString *> *)vcClass {
    [vcClass enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![[EYFloatManager shared].floatVcClass containsObject:obj]) {
            [[EYFloatManager shared].floatVcClass addObject:obj];
        }
    }];
}

+ (void)setMaxFLoatingCount:(int)maxCount{
    [EYFloatManager shared].MaxFloatViewArrayCount = maxCount;
}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    
    UIViewController *vc = self.floatBall.floatViewController;
    if (vc) {
        if (operation == UINavigationControllerOperationPush) {
            if (toVC != vc) {
                return nil;
            }
            EYTransitionPush *transition = [[EYTransitionPush alloc] init];
            return transition;
        } else if (operation == UINavigationControllerOperationPop) {
            if (fromVC != vc) {
                return nil;
            }
            EYTransitionPop *transition = [[EYTransitionPop alloc] init];
            return transition;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

#pragma mark - interactivePopGestureRecognizer
//当开始侧滑pop时调用此方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self ey_currentNavigationController].viewControllers.count > 1) {
        [[EYFloatManager shared] beginScreenEdgePanBack:gestureRecognizer];
        return YES;
    }
    return NO;
}

//利用CADisplayLink 来实现监听返回手势
- (void)beginScreenEdgePanBack:(UIGestureRecognizer *)gestureRecognizer {
    /*
     * 引用 gestureRecognizer
     * 开启 CADisplayLink
     * 显示右下视图
     **/
    if ([self.floatVcClass containsObject:NSStringFromClass([[self ey_currentViewController] class])]) {
        self.edgePan = (UIScreenEdgePanGestureRecognizer *) gestureRecognizer;
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [kWindow addSubview:self.floatArea];
        self.tempFloatViewController = [self ey_currentViewController];
        self.havePossible = NO;
        self.haveFloatView = NO;
        [self.floatViewArray enumerateObjectsUsingBlock:^(EYFloatBall*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.floatViewController isEqual:self.tempFloatViewController]) {
                self.haveFloatView = YES;
            }
        }];
    }
}

//操作判断
- (void)panBack:(CADisplayLink *)link {
    //手势状态
    if (self.edgePan.state == UIGestureRecognizerStateChanged) {
        //移动过程
        /*
         * 改变右下视图 frame
         * 判断手指是否进入右下视图中
         **/
        //手指在屏幕上的位置
        CGPoint tPoint = [self.edgePan translationInView:kWindow];
        CGFloat x = MAX(SCREEN_WIDTH + kFloatMargin - kCoef * tPoint.x, SCREEN_WIDTH - kFloatAreaR);
        CGFloat y = MAX(SCREEN_HEIGHT + kFloatMargin - kCoef * tPoint.x, SCREEN_HEIGHT - kFloatAreaR);
        CGRect rect = CGRectMake(x, y, kFloatAreaR, kFloatAreaR);
        //根据浮窗状态改变右下角视图状态
        if (self.haveFloatView) {
            self.floatArea.style = EYFloatAreaViewStyle_cancel;
        }else{
            self.floatArea.style = EYFloatAreaViewStyle_default;
        }
        self.floatArea.frame = rect;
        
        //手指在右下视图上的位置(若 x>0 && y>0 说明此时手指在右下视图上)
        CGPoint touchPoint = [kWindow convertPoint:[self.edgePan locationInView:kWindow] toView:self.floatArea];
        
        if (touchPoint.x > 0 && touchPoint.y > 0) {
            if (!self.showFloatBall) {
                //由于右下视图是1/4圆 所以需要这步判断
                if (pow((kFloatAreaR - touchPoint.x), 2) + pow((kFloatAreaR - touchPoint.y), 2) <= pow((kFloatAreaR), 2)) {
                    self.showFloatBall = YES;
                } else {
                    if (self.showFloatBall) {
                        self.showFloatBall = NO;
                    }
                }
            }
        } else {
            if (self.showFloatBall) {
                self.showFloatBall = NO;
            }
        }
    } else if (self.edgePan.state == UIGestureRecognizerStatePossible) {
        //手势结束状态标示
        if (self.havePossible == NO) {
            [UIView animateWithDuration:0.5 animations:^{
                self.floatArea.frame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT, kFloatAreaR, kFloatAreaR);
            } completion:^(BOOL finished) {
                /*
                 * 停止CADisplayLink
                 * 隐藏右下视图
                 * 显示/隐藏浮窗
                 **/
                [self.floatArea removeFromSuperview];
                self.floatArea = nil;
                [self.link invalidate];
                self.link = nil;
                if (self.showFloatBall) {
                    if (self.haveFloatView == NO) {
                        //超出maxCount提示
                        if (self.floatViewArray.count >= self.MaxFloatViewArrayCount) {
                            [self showAlert:[NSString stringWithFormat:@"最多只能添加%zd个",self.MaxFloatViewArrayCount]];
                            return;
                        }
                        EYFloatBall *floatBall = [[EYFloatBall alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kBallSizeR - margin, SCREEN_HEIGHT / 3, kBallSizeR, kBallSizeR)];
                        floatBall.delegate = self;
                        floatBall.alpha = 1.0f;
                        floatBall.floatViewController = self.tempFloatViewController;
                        //标示
                        floatBall.iconImageView.backgroundColor = floatBall.floatViewController.view.backgroundColor;
                        if (![self.floatViewArray containsObject:floatBall]) {
                            [kWindow addSubview:floatBall];
                            [self.floatViewArray insertObject:floatBall atIndex:0];
                        }
                        
                        self.floatBall = floatBall;
                        
                    }else{
                        [self floatBallEndMove:self.floatBall];
                    }
                    
                }else{
                    //手势结束刷新ball显示状态
                    if (self.haveFloatView && ![self.floatBall.floatViewController isEqual:[self ey_currentViewController]]) {
                        self.floatBall.alpha = 1.0f;
                    }
                }
                
            }];
        }
        self.havePossible = YES;
    }
    
}

- (void)showAlert:(NSString *)alertString{
    UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"提示" message:alertString?:@"" preferredStyle:(UIAlertControllerStyleAlert)];
    [alertV addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [[self ey_currentViewController]presentViewController:alertV animated:YES completion:nil];
}

#pragma mark - HKFloatBallDelegate
- (void)floatBallDidClick:(EYFloatBall *)floatBall {
    [[self ey_currentNavigationController] popViewControllerAnimated:NO];
    self.floatBall = floatBall;
    //将当前ball放到首位
    [self.floatViewArray removeObject:self.floatBall];
    [self.floatViewArray insertObject:self.floatBall atIndex:0];
    
    [[self ey_currentNavigationController] pushViewController:self.floatBall.floatViewController animated:YES];
}

- (void)floatBallBeginMove:(EYFloatBall *)floatBall {
    self.floatArea.style = EYFloatAreaViewStyle_cancel;
    [kWindow insertSubview:self.floatArea atIndex:1];
    [UIView animateWithDuration:0.5 animations:^{
        self.floatArea.frame = CGRectMake(SCREEN_WIDTH - kFloatAreaR, SCREEN_HEIGHT - kFloatAreaR, kFloatAreaR, kFloatAreaR);
    }];
    
    CGPoint center_ball = [kWindow convertPoint:floatBall.center toView:self.floatArea];
    if (pow((kFloatAreaR - center_ball.x), 2) + pow((kFloatAreaR - center_ball.y), 2) <= pow((kFloatAreaR), 2)) {
        if (!self.floatArea.highlight) {
            self.floatArea.highlight = YES;
        }
    } else {
        if (self.floatArea.highlight) {
            self.floatArea.highlight = NO;
        }
    }
}

- (void)floatBallEndMove:(EYFloatBall *)floatBall {
    
    if (self.floatArea.highlight) {
        self.tempFloatViewController = nil;
        [self.floatViewArray removeObject:floatBall];
        [floatBall removeFromSuperview];
        if (self.floatViewArray.count > 0) {
            self.floatBall = self.floatViewArray.firstObject;
        }else{
            self.floatBall = nil;
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.floatArea.frame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT, kFloatAreaR, kFloatAreaR);
    } completion:^(BOOL finished) {
        [self.floatArea removeFromSuperview];
        self.floatArea = nil;
    }];
}

#pragma mark - Setter
- (void)setShowFloatBall:(BOOL)showFloatBall {
    _showFloatBall = showFloatBall;
    self.floatArea.highlight = showFloatBall;
}

#pragma mark - Lazy
- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(panBack:)];
    }
    return _link;
}

- (EYFloatAreaView *)floatArea {
    if (!_floatArea) {
        _floatArea = [[EYFloatAreaView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH + kFloatMargin, SCREEN_HEIGHT + kFloatMargin, kFloatAreaR, kFloatAreaR)];
        _floatArea.style = EYFloatAreaViewStyle_default;
    };
    return _floatArea;
}

-(NSMutableArray *)floatViewArray{
    if (!_floatViewArray) {
        _floatViewArray = [NSMutableArray array];
    }
    return _floatViewArray;
}
@end
