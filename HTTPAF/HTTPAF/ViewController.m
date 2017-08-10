//
//  ViewController.m
//  HTTPAF
//
//  Created by cguo on 2017/5/27.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "ViewController.h"

#import "LoadingHUD.h"

#import "HttpTool.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    [HttpTool GET:@"http://ms.yonxin.com/api.php?app=api&mod=Message&act=unreadcount&api_type=&api_version=4.5.0&oauth_token=5351166962a0d4c41f1e13c49a4d4475&oauth_token_secret=13cad50321db751b804b7dd05aafa8a0" parameters:nil success:^(id responseObject) {
        NSLog(@"成功");
    } failure:^(NSError *error) {
        NSLog(@"失败");
    }];
    
    
    [HttpTool GET:@"http://ms.yonxin.com/api.php?app=api&mod=Message&act=unreadcount&api_type=&api_version=4.5.0&oauth_token=5351166962a0d4c41f1e13c49a4d4475&oauth_token_secret=13cad50321db751b804b7dd05aafa8a0" parameters:nil responseCache:^(id responseCache) {
        NSLog(@"reponseCache---%@",responseCache);
    } success:^(id responseObject) {
        NSLog(@"id---%@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"error--%@",error);
    }];
 
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self showAlertMes:@"弹出框输入"];

}

-(void)GetStareNum:(CGFloat)num
{
    NSLog(@"%f",num);
}
/*
 
 
 */


@end
