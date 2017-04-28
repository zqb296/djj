//
//  LXContact.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXContactVC.h"
#import "LXContactService.h"
#import "LXChatVC.h"

@interface LXContactVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (nonatomic, strong) NSMutableArray <LXUserM *>*contacts;


@end

@implementation LXContactVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contactTableView.tableFooterView = [UIView new];
    self.contactTableView.rowHeight = 60;
    
    [self loadContacts];
}

- (void)loadContacts
{
    [LXContactService getContactsResult:^(id infos, NSError *error) {
        if (error) {
            return ;
        }
        
        for (NSDictionary *info in infos) {
            [self.contacts addObject:[LXUserM yy_modelWithDictionary:info]];
        }
        
        [self.contactTableView reloadData];
    }];
}

#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusedString = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedString];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusedString];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"photo"];
    LXUserM *contactM = self.contacts[indexPath.row];
    
    cell.textLabel.text = contactM.name;
    cell.detailTextLabel.text = contactM.memo.length > 0 ? contactM.memo : @"暂无简介..." ;
    
    UIButton *btn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:@"对讲" forState:UIControlStateNormal];
    [btn setTitleColor: [LXUITool  topicColor] forState:UIControlStateNormal];
    
    cell.accessoryView = btn;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXUserM *contactM = self.contacts[indexPath.row];
    [self gotoChatWithUserm:contactM];
}

- (void)gotoChatWithUserm:(LXUserM *)userM
{
    LXChatVC *chatVC = [LXChatVC chatWithUserM:userM];
    [self.navigationController presentViewController:chatVC animated:YES completion:nil];
 }

- (NSMutableArray *)contacts
{
    if (_contacts == nil) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

@end
