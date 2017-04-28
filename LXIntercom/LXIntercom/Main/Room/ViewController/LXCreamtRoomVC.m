//
//  LXCreamtRoomVC.m
//  LXIntercom
//
//  Created by 余志杰 on 17/4/26.
//  Copyright © 2017年 LX. All rights reserved.
//

#import "LXCreamtRoomVC.h"
#import "LXRoomService.h"

@interface LXCreamtRoomVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *infos;
@property (nonatomic, strong) UIButton *submitBtn;


@end

@implementation LXCreamtRoomVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.infos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *reusedString = @"UITableViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedString];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusedString];
	}

	UITextField *tf = self.infos[indexPath.section];
	tf.frame = cell.bounds;
	[cell addSubview:tf];

	return cell;
}

- (UITableView *)tableView
{
	if (_tableView == nil) {
		_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
		_tableView.tableFooterView = self.submitBtn;
		[self.view addSubview:_tableView];
	}
	return _tableView;
}

- (void)submit
{
	
	self.submitBtn.enabled = NO;
	
	for (UITextField *t  in self.infos) {
		[t resignFirstResponder];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		[params setObject:[self.infos[0] text] forKey:@"name"];
		//	[params setObject:[self.infos[1] text] forKey:@"memo"];
		//	[params setObject:[self.infos[2] text] forKey:@"type"];
		//	[params setObject:[self.infos[3] text] ? @(1) : @(0) forKey:@"opened"];
		
		[LXRoomService createRoomPrams:params result:^(id succeed, NSError *error) {
			if (!error) {
				if (self.successBlock) {
					self.successBlock();
				}
				kAlertMsg(@"创建成功！");
				
				[self.navigationController popViewControllerAnimated:YES];
			}else{
				kAlertMsg(error.userInfo[kMsgKey]);
			}
			self.submitBtn.enabled = YES;

		}];
	});

}

- (UIButton *)submitBtn
{
	if (_submitBtn == nil) {
		_submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		[_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
		[_submitBtn setTitle:@"提交中..." forState:UIControlStateDisabled];

		[_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
		_submitBtn.backgroundColor = [LXUITool topicColor];
	}
	return _submitBtn;
}

- (NSMutableArray *)infos
{
	if (_infos == nil) {
		_infos = [NSMutableArray array];
		NSArray *arg = @[@"房名"];
		for (NSInteger i = 0; i < arg.count; i++) {
			UITextField *tf = [UITextField new];
			tf.placeholder = arg[i];
			[_infos addObject:tf];
		}
	}
	return _infos;
}


@end
