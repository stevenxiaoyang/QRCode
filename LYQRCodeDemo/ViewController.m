//
//  ViewController.m
//  LYQRCodeDemo
//
//  Created by LuYang on 16/4/11.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "ViewController.h"

static NSString *const cellIdentifity = @"CellId";
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSArray *controllerNameArray;
@property (nonatomic, strong)NSArray *cellNameArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
    self.cellNameArray = @[@"生成二维码",@"扫描二维码"];
    self.controllerNameArray = @[@"EncodeViewController",@"DecodeViewController"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifity];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cellNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifity forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifity];
    }
    cell.textLabel.text = _cellNameArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Class pushClass = NSClassFromString(_controllerNameArray[indexPath.row]);
    if ([pushClass isSubclassOfClass:[UIViewController class]]) {
        UIViewController *toVC = [pushClass new];
        toVC.view.backgroundColor = [UIColor whiteColor];
        toVC.title = _cellNameArray[indexPath.row];
        [self.navigationController pushViewController:toVC animated:YES];
    }
}
@end
