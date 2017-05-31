//
//  ViewController.m
//  HTTPAF
//
//  Created by cguo on 2017/5/27.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "ViewController.h"
#import "WTKStarView.h"
#import "LoadingHUD.h"
@interface ViewController ()<WTKStarViewDeleagte>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WTKStarView *view=[[WTKStarView alloc]initWithFrame:CGRectMake(50, 100, 150, 30) starSize:CGSizeMake(30, 30) withStyle:WTKStarTypeFloat];
    view.star=0;
    view.starBlock=^(NSString *stare){
        NSLog(@"%@",stare);
     };
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self EditProduct];
    [LoadingHUD showHUD];
}

-(void)GetStareNum:(CGFloat)num
{
    NSLog(@"%f",num);
}
/*
 
 
 */


@end
