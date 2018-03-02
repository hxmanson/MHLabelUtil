//
//  UILabel+MHLabelOption.h
//  OceanhighApp
//
//  Created by Oceanhigh on 16/1/22.
//  Copyright © 2016年 OH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (MHLabelUtil)

@property (nonatomic, assign)BOOL shouldAutoAdjustLabelHeight;
@property (nonatomic, assign)BOOL shouldAutoAdjustLabelWidth;
//@property (nonatomic, assign)BOOL autoAdjustLabelHeight;
@property (nonatomic, assign)NSNumberFormatterStyle numberFormatterStyle;
@property (nonatomic, assign)NSInteger decimalRemain;/**<保留小数位*/


#pragma mark - 文本尺寸计算方法
/**
 * Label文本适配（使用label文本属性）
 * 根据文字，Lable属性，调整Label尺寸
 
 @param isHeightSetting 自适配高度/宽度；YES：高度自适配；NO：宽度自适配
 @param text 文本内容
 */
-(void)autoReloadLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text;

/**
 * Label文本适配（自定义文本属性）
 * 根据文字，文字属性，调整Label尺寸
 
 @param isHeightSetting 自适配高度/宽度；YES：高度自适配；NO：宽度自适配
 @param text 文本内容
 @param attributeDict Label文字属性
 */
-(void)autoReloadLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text textAttribute:(NSDictionary *)attributeDict;

/**<两端对齐*/
//-(void)textJustify;


/**
 * 设置label的行间距，并根据是否自动适配高度/宽度，进行尺寸适配设置

 @param lineSpace 行间距
 @param text 需设置的文字，默认为label中的文字
 @param textFont 文字字体，默认为label字体
 @param textColor 文字颜色，默认为label字体颜色
 */
-(void)setLabelLineSpacing:(NSInteger)lineSpace withText:(NSString *)text textFont:(UIFont *)textFont textColor:(UIColor *)textColor;

@end
