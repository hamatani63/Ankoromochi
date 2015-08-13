//
//  AppDelegate.h
//  Ankoromochi
//
//  Created by 浜谷 光吉 on 2015/03/12.
//  Copyright (c) 2015 Mitsuyoshi Hamatani
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//受け渡したい変数
@property (nonatomic, retain) NSString *strMessage;


@end

