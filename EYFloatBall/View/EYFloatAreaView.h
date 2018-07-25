//
//  EYFloatAreaView.h
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EYFloatAreaViewStyle) {
    EYFloatAreaViewStyle_default,
    EYFloatAreaViewStyle_cancel,
};

@interface EYFloatAreaView : UIView
@property(nonatomic, assign) BOOL highlight;
@property(nonatomic, assign) EYFloatAreaViewStyle style;
@end
