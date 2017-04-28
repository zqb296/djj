//
//  LXSettingVC.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXSettingVC.h"
#import "LXLoginVC.h"
#import "LXUITool.h"

@interface LXSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@property (weak, nonatomic) IBOutlet UILabel *labelUserID;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end

@implementation LXSettingVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.settingTableView.tableFooterView = [UIView new];
    
    [self setupUserInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUserInfo) name:kNoticeKey_UserLoginSuccessed object:nil];
}

- (void)setupUserInfo
{
    LXUserM *u = [LXDataManager currentUser];
    self.labelUserID.text = u.userid;
    self.labelName.text = u.name;
}

#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusedString = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedString];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusedString];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"更改密码";
    }
    
    if (indexPath.row == 1) {
        cell.textLabel.text = @"免打扰";
        cell.accessoryView = [UISwitch new];
    }
    
    if (indexPath.row == 2) {
        cell.textLabel.text = @"登录";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
       UIViewController *vc =  [LXUITool getVC:[LXLoginVC self] storyboardName:@"Login"];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
}

@end
