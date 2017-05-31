//
//  BaseViewController.h
//  HTTPAF
//
//  Created by cguo on 2017/5/28.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    UILabel *_titleLabel;
    UIButton *_rightButton;
    UIButton *_leftButton;
    UIImageView *_titleImage;
    
}
@property (nonatomic,retain) UIButton *leftButton;
@property (nonatomic,retain) UIButton *rightButton;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UIImageView *titleImage;
@property (nonatomic,retain) UIView *lineTL;
@property (nonatomic,retain)UIActivityIndicatorView *rightIndictor;


- (void)leftButtonClick:(id)sender;
- (void)rightButtonClick:(id)sender;

@property (assign, nonatomic) BOOL isShowing;//当前视图是否在显示，小小一个isShowing，你可以拿来判断是否在当前视图来取消或者结束线程

-(void)stopRightIndictor;
-(void)beginRightIndictor;
/**
 *退出程序(需要用户重新点击进入)
 */
-(void)EditProduct;

@end
