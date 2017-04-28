//
//  LXDataManager.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXUserM.h"


#define kCurrentUserID [LXDataManager currentUser].userid

@interface LXDataManager : NSObject

+ (void)saveCurrentUser:(LXUserM *)user;
+ (LXUserM *)currentUser;

@end
