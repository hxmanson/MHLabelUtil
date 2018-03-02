//
//  NSString+MHStringUtil.m
//  MHLabelUtil
//
//  Created by mansonhu on 2018/3/2.
//

#import "NSString+MHStringUtil.h"
#import <objc/runtime.h>


@implementation NSString (MHStringUtil)

#pragma mark - 尺寸计算
//文本尺寸计算
-(CGSize)mhTextHeight:(BOOL)isHeightSetting andFrame:(CGRect)frame textAttribute:(NSDictionary *)attributeDict
{
    CGSize size = CGSizeZero;
    if (attributeDict)
    {
        CGSize adjustSize = CGSizeMake(isHeightSetting?CGRectGetWidth(frame):MAXFLOAT, isHeightSetting?MAXFLOAT:CGRectGetHeight(frame));
        size = [self boundingRectWithSize:adjustSize  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeDict context:nil].size;
        
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
    }
    
    return size;
}


@end
