//
//  UILabel+MHLabelOption.m
//  OceanhighApp
//
//  Created by Oceanhigh on 16/1/22.
//  Copyright © 2016年 OH. All rights reserved.
//

#import "UILabel+MHLabelOption.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

static const void *kAutoAdjustLabelWidthKey = &kAutoAdjustLabelWidthKey;
static const void *kAutoAdjustLabelHeightKey = &kAutoAdjustLabelHeightKey;
static const void *kNumberFormatterStyleKey = &kNumberFormatterStyleKey;
static const void *kDecimalRemainKey = &kDecimalRemainKey;

@implementation UILabel (MHLabelOption)

@dynamic shouldAutoAdjustLabelWidth;
@dynamic shouldAutoAdjustLabelHeight;
@dynamic numberFormatterStyle;
@dynamic decimalRemain;

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //case1: 替换实例方法
        Class selfClass = [self class];
        //case2: 替换类方法
//        Class selfClass = object_getClass([self class]);
        
        //源方法的SEL和Method
        SEL oriSEL = @selector(setText:);
        Method oriMethod = class_getInstanceMethod(selfClass, oriSEL);
        
        //交换方法的SEL和Method
        SEL cusSEL = @selector(mySetText:);
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


//自动匹配label宽度/长度，根据文字
-(void)autoAdjustLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text
{
    [self autoAdjustLabelHeight:isHeightSetting withText:text textAttribute:nil];
}

//自动匹配label宽度/长度，根据文字以及自定义文字属性
-(void)autoAdjustLabelHeight:(BOOL)isHeightSetting withText:(NSString*)text textAttribute:(NSDictionary *)attributeDict
{
    CGSize textSize = [self adjustLabelHeight:isHeightSetting withText:text textAttribute:attributeDict];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if ((constraint.firstAttribute == NSLayoutAttributeHeight || constraint.secondAttribute == NSLayoutAttributeHeight) && isHeightSetting)
        {
//            textSize.height +=1;
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

//尺寸计算
-(CGSize)adjustLabelHeight:(BOOL)isHeightSetting withText:(NSString *)text
{
    NSDictionary *attribute = @{NSFontAttributeName:self.font};
    CGSize size = [self adjustLabelHeight:isHeightSetting withText:text textAttribute:attribute];
    
    return size;
}

//根据文字，文字属性，计算尺寸
-(CGSize)adjustLabelHeight:(BOOL)isHeightSetting withText:(NSString *)text textAttribute:(NSDictionary *)attributeDict
{
    if (!attributeDict)
    {
        //nil
        attributeDict = @{NSFontAttributeName:self.font};
    }
    
    CGSize adjustSize = CGSizeMake(isHeightSetting?self.frame.size.width:0, isHeightSetting?0:self.frame.size.height);
    CGSize size = [text boundingRectWithSize:adjustSize  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeDict context:nil].size;
    
    if (isHeightSetting)
    {
        //高度调整，则宽度不变
        size.width = adjustSize.width;
    }
    else
    {
        //宽度调整，则高度不变
        size.height = adjustSize.height;
    }
    
    return size;
}

//两端对齐
-(void)changeAlignmentLeftAndRight
{
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size;
    CGFloat margin = (self.frame.size.width - textSize.width) / (self.text.length - 1);
    NSNumber *number = [NSNumber numberWithFloat:margin];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
    [attributedString addAttribute:(id)kCTKernAttributeName value:number range:NSMakeRange(0, self.text.length -1)];
    self.attributedText = attributedString;
}

//格式化字符串
-(NSString*)formatterNumberText
{
    NSInteger decimalRemain = [objc_getAssociatedObject(self, &kDecimalRemainKey) integerValue];
    NSNumber *formatterNumber = objc_getAssociatedObject(self, &kNumberFormatterStyleKey);
    NSNumberFormatterStyle numberFormatterStyle = formatterNumber.integerValue;
    
    if (numberFormatterStyle == NSNumberFormatterNoStyle)
    {
        return self.text;
    }
    else
    {
        //不等于默认style
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
//        formatter.numberStyle = numberFormatterStyle;
        NSString *numberFormat = @"###,###";
        for (int i= 0; i<decimalRemain; i++)
        {
            NSString *appendStr = @"0";
            if (i==0)
            {
                //第一位
                appendStr = [@"." stringByAppendingString:appendStr];
            }
            
            numberFormat = [numberFormat stringByAppendingString:appendStr];
        }
        
        [formatter setPositiveFormat:numberFormat];
        NSNumber *strConvertNumber = [formatter numberFromString:self.text];
        NSString *newAmount = [formatter stringFromNumber:strConvertNumber];
        
//        NSString *newAmount = [formatter stringFromNumber:strConvertNumber];
        
        return newAmount;
    }
}

//提取数字（待用）
-(NSInteger)findNumFromStr:(NSString *)originalString
{
    // Intermediate
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        [numberString appendString:tempStr];
        tempStr = @"";
    }
    // Result.
    NSInteger number = [numberString integerValue];
    
    return number;
}

//Method Swizzling替换系统原有方法: setText:
-(void)mySetText:(NSString *)text
{
    //调用实例原有方法setText:
    [self mySetText:text];
    //设置文字格式
    [self mySetText:[self formatterNumberText]];
    
    //获取关联对象isHeight
    BOOL isHeight = [objc_getAssociatedObject(self, &kAutoAdjustLabelHeightKey) boolValue];
    BOOL isWidth = [objc_getAssociatedObject(self, &kAutoAdjustLabelWidthKey) boolValue];
    
//    OHLog(@"frame: %@",NSStringFromCGRect(self.frame));
    //设置label尺寸
    if (isHeight)
    {
        [self autoAdjustLabelHeight:YES withText:self.text];
    }
    
    if (isWidth)
    {
        [self autoAdjustLabelHeight:NO withText:self.text];
    }
    
}

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
        [self autoAdjustLabelHeight:NO withText:self.text];
    }
}

-(void)setShouldAutoAdjustLabelHeight:(BOOL)shouldAutoAdjustLabelHeight
{
    if (shouldAutoAdjustLabelHeight)
    {
        //启用高度自适应
        objc_setAssociatedObject(self, &kAutoAdjustLabelHeightKey, @(shouldAutoAdjustLabelHeight), OBJC_ASSOCIATION_ASSIGN);
    }
    
//    OHLog(@"frame2:%@",NSStringFromCGRect(self.frame));
    
    if (self.text && ![self.text isEqualToString:@""])
    {
        //当前label有值
        [self autoAdjustLabelHeight:YES withText:self.text];
    }

}

-(void)setNumberFormatterStyle:(NSNumberFormatterStyle)numberFormatterStyle
{
    objc_setAssociatedObject(self, &kNumberFormatterStyleKey, @(numberFormatterStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self mySetText:self.text];
}

-(void)setDecimalRemain:(NSInteger)decimalRemain
{
    objc_setAssociatedObject(self, &kDecimalRemainKey, @(decimalRemain), OBJC_ASSOCIATION_ASSIGN);
}

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
        [self autoAdjustLabelHeight:YES withText:text textAttribute:attributeDict];
    }
    
    if (isWidth)
    {
        [self autoAdjustLabelHeight:NO withText:text textAttribute:attributeDict];
    }
}

@end
