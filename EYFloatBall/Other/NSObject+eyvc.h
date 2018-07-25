//
//  NSObject+eyvc.h
//  EYWeChatFloat
//
//  Created by 尹华东 on 2018/7/25.
//  Copyright © 2018年 yinhuadong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (eyvc)
- (UIViewController *)ey_currentViewController;
- (UITabBarController *)ey_currentTabBarController;
- (UINavigationController *)ey_currentNavigationController;
@end
