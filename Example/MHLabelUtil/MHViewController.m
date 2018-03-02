//
//  MHViewController.m
//  MHLabelUtil
//
//  Created by mansonhu on 02/28/2018.
//  Copyright (c) 2018 mansonhu. All rights reserved.
//

#import "MHViewController.h"
#import <MHLabelUtil/UILabel+MHLabelUtil.h>

#define kPivateText_1 @"点击下方Change按钮"
#define kPivateText_2 @",将会看到此处文本高度变化"

@interface MHViewController ()
@property (nonatomic, strong) NSMutableString *changeText;
@property (nonatomic, assign) NSInteger changeCount;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _changeText = [NSMutableString string];
    _changeCount = 0;
    [self textAppendContent];
    _label.shouldAutoAdjustLabelHeight = YES;
//    [_label textJustify];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textAppendContent
{
    [_changeText appendString:_changeCount%2==0?kPivateText_1:kPivateText_2];
    NSLog(@"change:%@",_changeText);
    _changeCount +=1;
    _label.text = _changeText;
}

- (IBAction)btnChangeAction:(UIButton *)btn
{
    [self textAppendContent];
}
@end
