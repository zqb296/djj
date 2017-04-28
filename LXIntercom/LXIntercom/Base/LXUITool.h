//
//  LXUITool.h
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXUITool : NSObject

+ (UIViewController *)getVC:(Class)VCClass  storyboardName:(NSString *)name;
+ (UIColor *)topicColor;
+ (UIImage*) createImageWithColor:(UIColor*) color;

@end
