//
//  UILabel+MHLabelOption.m
//  OceanhighApp
//
//  Created by Oceanhigh on 16/1/22.
//  Copyright © 2016年 OH. All rights reserved.
//

#import "UILabel+MHLabelUtil.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import <NSString+MHStringUtil.h>

static const void *kAutoAdjustLabelWidthKey = &kAutoAdjustLabelWidthKey;
static const void *kAutoAdjustLabelHeightKey = &kAutoAdjustLabelHeightKey;
static const void *kNumberFormatterStyleKey = &kNumberFormatterStyleKey;


@implementation UILabel (MHLabelUtil)
@dynamic shouldAutoAdjustLabelWidth;
@dynamic shouldAutoAdjustLabelHeight;
@dynamic numberFormatterStyle;
@dynamic decimalRemain;

//Class生成之前需要替换原有实例方法 -setText:
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //替换实例方法
        Class selfClass = [self class];
        
        //源方法的SEL和Method
        SEL oriSEL = @selector(setText:);
        Method oriMethod = class_getInstanceMethod(selfClass, oriSEL);
        
        //交换方法的SEL和Method
        SEL cusSEL = @selector(mhSetText:);
        Method cusMethod = class_getInstanceMethod(selfClass, cusSEL);
        
        //先尝试給源方法添加实现，这里是为了避免源方法没有实现的情况
        BOOL addSucc = class_addMethod(selfClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (addSucc) {
            //添加成功：将源方法的实现替换到交换方法的实现
            class_replaceMethod(selfClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        }else {
            //添加失败：说明源方法已经有实现，直接将两个方法的实现交换即可
            method_exchangeImplementations(oriMethod, cusMethod);
        }
    });
}

#pragma mark - 属性设置
//宽度自适应
-(void)setShouldAutoAdjustLabelWidth:(BOOL)shouldAutoAdjustLabelWidth
{
    if (shouldAutoAdjustLabelWidth)
    {
        //启用宽度自适应
        objc_setAssociatedObject(self, &kAutoAdjustLabelWidthKey, @(shouldAutoAdjustLabelWidth), OBJC_ASSOCIATION_ASSIGN);
    }
    
    if (self.text && ![self.text isEqualToString:@""])
    {
        [self autoReloadLabelHeight:NO withText:self.text];
    }
}

-(void)setShouldAutoAdjustLabelHeight:(BOOL)shouldAutoAdjustLabelHeight
{
    if (shouldAutoAdjustLabelHeight)
    {
        //启用高度自适应
        objc_setAssociatedObject(self, &kAutoAdjustLabelHeightKey, @(shouldAutoAdjustLabelHeight), OBJC_ASSOCIATION_ASSIGN);
    }
    
    if (self.text && ![self.text isEqualToString:@""])
    {
        //当前label有值
        [self autoReloadLabelHeight:YES withText:self.text];
    }
}

-(void)setNumberFormatterStyle:(NSNumberFormatterStyle)numberFormatterStyle
{
    objc_setAssociatedObject(self, &kNumberFormatterStyleKey, @(numberFormatterStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self mhSetText:self.text];
}

#pragma mark - 重写实例方法 -setText:
//Method Swizzling替换系统原有方法: setText:
-(void)mhSetText:(NSString *)text
{
    //调用实例原有方法setText:
    [self mhSetText:text];
    //获取关联对象isHeight
    BOOL isHeight = [objc_getAssociatedObject(self, &kAutoAdjustLabelHeightKey) boolValue];
    BOOL isWidth = [objc_getAssociatedObject(self, &kAutoAdjustLabelWidthKey) boolValue];
    
    //设置label尺寸
    if (isHeight)
    {
        [self autoReloadLabelHeight:YES withText:self.text];
    }
    
    if (isWidth)
    {
        [self autoReloadLabelHeight:NO withText:self.text];
    }
    
}

#pragma mark - 文本尺寸计算方法
//Label适配核心方法（使用label文本属性）
-(void)autoReloadLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text
{
    [self autoReloadLabelHeight:isHeightSetting withText:text textAttribute:nil];
}

//Label适配核心方法（自定义文本属性）
-(void)autoReloadLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text textAttribute:(NSDictionary *)attributeDict
{
    if (!attributeDict)
    {
        //nil
        attributeDict = @{NSFontAttributeName:self.font};
    }
    
    CGSize textSize = [text mhTextHeight:isHeightSetting andFrame:self.frame textAttribute:attributeDict];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if ((constraint.firstAttribute == NSLayoutAttributeHeight || constraint.secondAttribute == NSLayoutAttributeHeight) && isHeightSetting)
        {
            textSize.height +=1;
            constraint.constant = textSize.height;
        }
        else if ((constraint.firstAttribute == NSLayoutAttributeWidth || constraint.secondAttribute == NSLayoutAttributeWidth)&& !isHeightSetting)
        {
            textSize.width +=1;
            constraint.constant = textSize.width;
        }
    }
    
    CGRect frame = self.frame;
    frame.size = textSize;
    self.frame = frame;
}

#pragma mark - UILabel Utils
////两端对齐
//-(void)textJustify
//{
////    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size;
//    CGSize textSize = [self.text mhTextHeight:YES andFrame:self.frame textAttribute:nil];
//    CGFloat margin = (CGRectGetWidth(self.frame) - textSize.width) / (self.text.length - 1);
//    NSNumber *number = [NSNumber numberWithFloat:margin];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
//    [attributedString addAttribute:(id)kCTKernAttributeName value:number range:NSMakeRange(0, self.text.length -1)];
//    self.attributedText = attributedString;
//}


//调整行间距
-(void)setLabelLineSpacing:(NSInteger)lineSpace withText:(NSString *)text textFont:(UIFont *)textFont textColor:(UIColor *)textColor
{
    text = text?text:self.text;
    textColor = textColor?textColor:self.textColor;
    textFont = textFont?textFont:self.font;
    
    // 调整行间距
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    // NSKernAttributeName字体间距
    NSDictionary *attributes = @{ NSParagraphStyleAttributeName:paragraphStyle};
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    // 创建文字属性
    NSDictionary * attriBute = @{NSForegroundColorAttributeName:textColor,NSFontAttributeName:textFont};
    [attriStr addAttributes:attriBute range:NSMakeRange(0, text.length)];
    
    self.attributedText = attriStr;
    
    //设置label高度
    //获取关联对象isHeight
    BOOL isHeight = [objc_getAssociatedObject(self, &kAutoAdjustLabelHeightKey) boolValue];
    BOOL isWidth = [objc_getAssociatedObject(self, &kAutoAdjustLabelWidthKey) boolValue];
    
    //设置label尺寸
    NSRange attributeRange = NSMakeRange(0, text.length);
    NSDictionary *attributeDict = [self.attributedText attributesAtIndex:0 effectiveRange:&attributeRange];
    if (isHeight)
    {
        [self autoReloadLabelHeight:YES withText:text textAttribute:attributeDict];
    }
    
    if (isWidth)
    {
        [self autoReloadLabelHeight:NO withText:text textAttribute:attributeDict];
    }
}

@end
