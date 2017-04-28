//
//  LXUITool.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXUITool.h"
#import "LXLoginVC.h"

@implementation LXUITool

+ (UIViewController *)getVC:(Class)VCClass  storyboardName:(NSString *)name
{
    UIViewController *vc;
    if (VCClass == nil || name.length == 0)return nil;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]];
    if (sb) {
        vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass(VCClass)];
    }
    
    return vc;
}

+ (UIColor *)topicColor
{
    return [UIColor colorWithRed:36/255. green:66/255. blue:162/255. alpha:1];
}

+(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
