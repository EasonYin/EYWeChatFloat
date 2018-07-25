//
//  EYFloatBall.h
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EYFloatBallDelegate;
@interface EYFloatBall : UIView
@property(nonatomic, weak) id<EYFloatBallDelegate> delegate;
@property(nonatomic, strong) UIImageView *iconImageView;
@property(nonatomic, strong) UIViewController *floatViewController;

@end

@protocol EYFloatBallDelegate <NSObject>
@optional
- (void)floatBallDidClick:(EYFloatBall *)floatBall;
- (void)floatBallBeginMove:(EYFloatBall *)floatBall;
- (void)floatBallEndMove:(EYFloatBall *)floatBall;
@end
