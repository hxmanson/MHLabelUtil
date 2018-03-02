//
//  NSString+MHStringUtil.h
//  MHLabelUtil
//
//  Created by mansonhu on 2018/3/2.
//

#import <Foundation/Foundation.h>

@interface NSString (MHStringUtil)

/**
 * 文本尺寸计算
 * 根据文字，文字属性，计算文本尺寸
 
 @param isHeightSetting 自适配高度/宽度；YES：高度自适配；NO：宽度自适配
 @param frame 文本框初始frame
 @param attributeDict 文本宽高尺寸
 @return 文本尺寸
 */
-(CGSize)mhTextHeight:(BOOL)isHeightSetting andFrame:(CGRect)frame textAttribute:(NSDictionary *)attributeDict;

@end
