//
//  LXContactM.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/20.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXUserM.h"

@implementation LXUserM

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self yy_modelEncodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        return  [self yy_modelInitWithCoder:aDecoder];
    }
    
    return nil;
}

- (NSString *)selfTopic
{
	if (self.userid) {
		return [NSString stringWithFormat:@"user/%@/#",self.userid];
	}else{
		return nil;
	}
}

@end
