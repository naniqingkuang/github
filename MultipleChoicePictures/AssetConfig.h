//
//  AECConfig.h
//  AndEducationClient
//
//  Created by 独孤剑道(张洋) on 15/4/10.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#ifndef AndEducationClient_AECConfig_h
#define AndEducationClient_AECConfig_h

#pragma mark - 常量设定

#define W_WIDTH [UIScreen mainScreen].bounds.size.width
#define H_HIGH  [UIScreen mainScreen].bounds.size.height

#pragma mark - 判断系统

#define IS_IOS7_LATER   ([UIDevice currentDevice].systemVersion.floatValue > 6.99)
#define IS_IOS8_LATER   ([UIDevice currentDevice].systemVersion.floatValue > 7.99)


// RGB
#define COLOR_RGBA_BLACK [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] // 黑色

#define COLOR_RGBA_BLACK_SET(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/1.0f] // 设置黑色

// 16进制色值
#define COLOR_16HEX_LIGHT_BLUE_SET(HEXValue) [UIColor colorWithRed:((float)((HEXValue & 0xFFFFFF) >> 16))/255.0 green:((float)((HEXValue & 0xFFFF) >> 8))/255.0 blue:((float)(HEXValue & 0xFF))/255.0 alpha:1.0] // 设置浅蓝色
#define COLOR_16HEX_LIGHT_BLUE COLOR_16HEX_LIGHT_BLUE_SET(0xCCFFFF) // 浅蓝色

#pragma mark - =====投资去_iOS_字号色值表=====
// 色值
#define COLOR_0 COLOR_RGBA_BLACK_SET(128, 183, 39, 1) // 绿色
#define COLOR_1 COLOR_16HEX_LIGHT_BLUE_SET(0xFFE77BC2) // 粉红色
#define COLOR_2 COLOR_16HEX_LIGHT_BLUE_SET(0xf8f8f8) // 浅灰白色
#define COLOR_3 COLOR_16HEX_LIGHT_BLUE_SET(0xffffff) // 白色
#define COLOR_4 COLOR_16HEX_LIGHT_BLUE_SET(0x333333) // 黑色
#define COLOR_5 COLOR_16HEX_LIGHT_BLUE_SET(0x666666) // 黑灰色
#define COLOR_6 COLOR_16HEX_LIGHT_BLUE_SET(0x999999) // 浅灰黑色
#define COLOR_7 COLOR_16HEX_LIGHT_BLUE_SET(0xbbbbbb) // 灰色
#define COLOR_8 COLOR_16HEX_LIGHT_BLUE_SET(0x00a5e0) // 蓝色
#define COLOR_9 COLOR_16HEX_LIGHT_BLUE_SET(0xff8000) // 橘黄色
#define COLOR_10 COLOR_RGBA_BLACK_SET(146., 192., 70., 1) // status bar 绿色
#define COLOR_11 COLOR_RGBA_BLACK_SET(242., 242., 242., 1) // 页面背景浅灰色
#define COLOR_12 COLOR_RGBA_BLACK_SET(231., 231., 231., 1) // 横线浅灰色
#define COLOR_13 COLOR_16HEX_LIGHT_BLUE_SET(0xFF57BBCB) // 浅蓝色
#define COLOR_14 COLOR_16HEX_LIGHT_BLUE_SET(0xA020F0) // 紫

#pragma mark - =====字体对齐======
// 首页对齐
#define HOME_TEXT_LEFT   NSTextAlignmentLeft    // 居左
#define HOME_TEXT_CENTER NSTextAlignmentCenter  // 居中
#define HOME_TEXT_RIGHT  NSTextAlignmentRight   // 居右

#define HIDE_STATUS_BAR_VIEW @"hide_status_view"
#define SHOW_STATUS_BAR_VIEW @"show_status_view"


#define kSelectionLabKey        @"selectionLabKey"
#define kSelectionImageKey      @"selectionOImageKey"

#endif
