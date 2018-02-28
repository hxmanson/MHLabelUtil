//
//  UILabel+MHLabelOption.h
//  OceanhighApp
//
//  Created by Oceanhigh on 16/1/22.
//  Copyright © 2016年 OH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (MHLabelOption)

@property (nonatomic, assign)BOOL shouldAutoAdjustLabelHeight;
@property (nonatomic, assign)BOOL shouldAutoAdjustLabelWidth;
//@property (nonatomic, assign)BOOL autoAdjustLabelHeight;
@property (nonatomic, assign)NSNumberFormatterStyle numberFormatterStyle;
@property (nonatomic, assign)NSInteger decimalRemain;/**<保留小数位*/

//自动匹配label宽度/长度
-(void)autoAdjustLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text;
-(CGSize)adjustLabelHeight:(BOOL)isHeightSetting withText:(NSString *)text;

-(void)changeAlignmentLeftAndRight;/**<两端对齐*/


/**
 * 设置label的行间距，并根据是否自动适配高度/宽度，进行尺寸适配设置

 @param lineSpace 行间距
 @param text 需设置的文字，默认为label中的文字
 @param textFont 文字字体，默认为label字体
 @param textColor 文字颜色，默认为label字体颜色
 */
-(void)setLabelLineSpacing:(NSInteger)lineSpace withText:(NSString *)text textFont:(UIFont *)textFont textColor:(UIColor *)textColor;

@end
