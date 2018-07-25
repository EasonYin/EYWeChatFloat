//
//  NSObject+eyvc.m
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import "NSObject+eyvc.h"

@implementation NSObject (eyvc)
- (UIViewController *)ey_currentViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *) vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *) vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else {
            break;
        }
    }
    return vc;
}

- (UINavigationController *)ey_currentNavigationController {
    return [self ey_currentViewController].navigationController;
}

- (UITabBarController *)ey_currentTabBarController {
    return [self ey_currentViewController].tabBarController;
}
@end
