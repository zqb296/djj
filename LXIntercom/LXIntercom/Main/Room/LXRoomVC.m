//
//  LXRoomVC.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/19.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXRoomVC.h"
#import "LXRoomService.h"
#import "LXRoomM.h"
#import "LXChatVC.h"
#import "LXCreamtRoomVC.h"

@interface LXRoomVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *roomTableView;
@property (nonatomic, strong) NSMutableArray <LXRoomM *>* rooms;


@end

@implementation LXRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"对讲室";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"创建" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createRoom) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = bar;
    
    self.roomTableView.tableFooterView = [UIView new];
    self.roomTableView.rowHeight = 60;

    [self loadRooms];
}

- (void)createRoom
{
	LXCreamtRoomVC *createRoomVC = [LXCreamtRoomVC new];
	createRoomVC.successBlock = ^{
		[self loadRooms];
	};
	
	createRoomVC.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:createRoomVC animated:YES];
}

- (void)loadRooms
{
	[self.rooms removeAllObjects];
    [LXRoomService getRoomsResult:^(id infos, NSError *error) {
        if (error) {
            return ;
        }
        
        for (NSDictionary *info in infos) {
            [self.rooms addObject:[LXRoomM yy_modelWithDictionary:info]];
        }
        
        [self.roomTableView reloadData];
    }];
}

#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusedString = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedString];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusedString];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"photo"];
    cell.textLabel.text = [self.rooms[indexPath.row] name];
    
    UIButton *btn =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:@"进入" forState:UIControlStateNormal];
    [btn setTitleColor: [LXUITool  topicColor] forState:UIControlStateNormal];
    
    cell.accessoryView = btn;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXRoomM *contactM = self.rooms[indexPath.row];
    [self gotoChatWithRoomM:contactM];
}

- (void)gotoChatWithRoomM:(LXRoomM *)room
{
    LXChatVC *chatVC = [LXChatVC chatWithRoomM:room];
    [self.navigationController presentViewController:chatVC animated:YES completion:nil];
}

- (NSMutableArray *)rooms
{
    if (_rooms == nil) {
        _rooms = [NSMutableArray array];
    }
    return _rooms;
}

@end
