//
//  EYFloatManager.h
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EYFloatBall.h"

@interface EYFloatManager : NSObject

@property(nonatomic, strong) EYFloatBall *floatBall;
@property(nonatomic, strong) NSMutableArray *floatViewArray;
@property(nonatomic, assign) int MaxFloatViewArrayCount;

+ (instancetype)shared;
+ (void)addFloatVcs:(NSArray<NSString *> *)vcClass;//注意.在导航控制器实例化之后调用
+ (void)setMaxFLoatingCount:(int)maxCount;//设置最大浮窗数量

- (void)beginScreenEdgePanBack:(UIGestureRecognizer *)gestureRecognizer;

@end
