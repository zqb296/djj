//
//  LXDataManager.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXDataManager.h"

static NSString *kCurrentUserKey = @"kCurrentUserKey";

#define kSaveObject(object,key)     if (key) { [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];}
#define kGetObjectForKey(key)           key?[[NSUserDefaults standardUserDefaults] objectForKey:key] : nil


@implementation LXDataManager



+ (void)saveCurrentUser:(LXUserM *)user
{
   NSData *userData =  [NSKeyedArchiver archivedDataWithRootObject:user];
    kSaveObject(userData, kCurrentUserKey);
}

+ (LXUserM *)currentUser
{
    NSData *userData = kGetObjectForKey(kCurrentUserKey);
   return  [NSKeyedUnarchiver unarchiveObjectWithData:userData];
}

@end
