//
//  LXChatVC.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/21.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXRoomM.h"
#import "LXUserM.h"

@interface LXChatVC : UIViewController

+ (instancetype)chatWithRoomM:(LXRoomM *) roomM;
+ (instancetype)chatWithUserM:(LXUserM *) userM;

@end
