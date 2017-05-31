//
//  BaseViewController.m
//  HTTPAF
//
//  Created by cguo on 2017/5/28.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "BaseViewController.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"



#define MainScreenHeight [UIScreen mainScreen].bounds.size.height
#define MainScreenWidth [UIScreen mainScreen].bounds.size.width
@interface BaseViewController ()<UIAlertViewDelegate>

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isShowing = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopRightIndictor];
    _isShowing = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden =YES;

    _isShowing = YES;
    //	self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _titleImage = [[UIImageView alloc]init];
    _titleImage.frame = CGRectMake(0, 0, MainScreenWidth, 44);
    _titleImage.backgroundColor = [UIColor whiteColor];
    _titleImage.userInteractionEnabled = YES;
    [self.view addSubview:_titleImage];
    
    
    _lineTL = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, MainScreenWidth, 0.5)];
    _lineTL.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.88 alpha:1];
    [_titleImage addSubview:_lineTL];
    
    _titleLabel = [[UILabel alloc]init];
    [_titleLabel setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont systemFontOfSize:20.0]];
    _titleLabel.frame = CGRectMake(50, 10, MainScreenWidth-100, 34);
    [_titleImage addSubview:_titleLabel];
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.frame = CGRectMake(0, 11, 44, 44);
    [_leftButton setTitleColor:[UIColor colorWithRed:255/255.0 green:158/255.0 blue:0/255.0 alpha:1.0] forState:0];
    [_leftButton setImage:[UIImage imageNamed:@"fanhuijiantou"] forState:0];
    [_leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_titleImage addSubview:_leftButton];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(MainScreenWidth-52, 11, 44, 44);
    [_rightButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:0];
    [_rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_titleImage addSubview:_rightButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f) {
        _titleImage.frame = CGRectMake(0, 0, MainScreenWidth, 64);
        _titleLabel.frame = CGRectMake(50, 27, MainScreenWidth-100, 34);
        _leftButton.frame = CGRectMake(0, 22, 54, 44);
        _rightButton.frame = CGRectMake(MainScreenWidth-52, 22, 53, 44);
        _lineTL.frame = CGRectMake(0, 63.5, MainScreenWidth, 0.5);
    }
    _rightIndictor = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _rightIndictor.frame = self.rightButton.frame;
    [_titleImage addSubview:_rightIndictor];
    
    //如果右滑手势不成功就打开
    /*
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.navigationController.interactivePopGestureRecognizer.delegate= (id<UIGestureRecognizerDelegate>)self;
    });
    
    */
    
}
//代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
 //是否支持右滑返回
    return self.navigationController.childViewControllers.count > 1;
}
-(void)EditProduct
{
    UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"需要退出程序重新打开" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
    [view show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"退出程序");
    [self exitApplication];
}

- (void)exitApplication {
    
    [UIView beginAnimations:@"exitApplication" context:nil];
    
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationDelegate:self];
    
    //     [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.view.window cache:NO];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view  cache:NO];
    
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    
    //self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    
    [UIApplication sharedApplication].keyWindow.bounds = CGRectMake(0, 0, 0, 0);
    
    [UIView commitAnimations];
    
}



- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if ([animationID compare:@"exitApplication"] == 0) {
        
        exit(0);
        
    }
    
}


-(void)stopRightIndictor
{
    _rightButton.hidden = NO;
    if (_rightIndictor.isAnimating) {
        [_rightIndictor stopAnimating];
    }
}


-(void)beginRightIndictor
{
    _rightButton.hidden = YES;
    if (!_rightIndictor.isAnimating) {
        [_rightIndictor startAnimating];
    }
}



-(void)leftButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClick:(id)sender {
    
}

-(void)showMes:(NSString*)mes
{
    
    [self.view.window makeToast:mes];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
