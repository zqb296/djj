//
//  LXContactM.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LXUserM : NSObject<NSCoding>

@property (nonatomic, strong) NSString *userid;

@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *pwd;

@end
