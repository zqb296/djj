//
//  LXBaseVC.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXBaseVC.h"

@interface LXBaseVC ()

@end

@implementation LXBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
