//
//  LXLoginVC.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXLoginVC.h"
#import "LXLoginService.h"

@interface LXLoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldUseName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;

@end

@implementation LXLoginVC

+ (instancetype)loginVC
{
    return (LXLoginVC*)[LXUITool getVC:self storyboardName:@"Login"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textFieldUseName.attributedPlaceholder  = [self textFieldAttrWithText:@"账号"];
    self.textFieldPassword.attributedPlaceholder = [self textFieldAttrWithText:@"密码"];
}

- (NSAttributedString *)textFieldAttrWithText:(NSString *)text
{
    return  [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.7]}];
    
}

- (IBAction)closeButtonAction:(id)sender
{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)loginAction:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *account = self.textFieldUseName.text;
    NSString *pwd = self.textFieldPassword.text;

    [LXLoginService loginWithUserName:account passWord:pwd result:^(id succeed, NSError *error) {
        if (error) {
            NSString *msg = error.userInfo[kMsgKey];
            kAlertMsg(msg?:@"请求出错，请重新尝试登录");
        }else{
            if ([succeed isKindOfClass:[NSDictionary class]]) {
                LXUserM *userM = [LXUserM yy_modelWithDictionary:succeed];
                [LXDataManager saveCurrentUser:userM];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNoticeKey_UserLoginSuccessed object:userM];
    
                kAlertMsg(@"登录成功");
            }
        }
    }];
}



@end
