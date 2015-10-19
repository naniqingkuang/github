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

#pragma mark - 判断设备

#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750,1334), [[UIScreen mainScreen] currentMode].size) : NO)

#pragma mark - 判断系统

#define IS_IOS7_LATER   ([UIDevice currentDevice].systemVersion.floatValue > 6.99)
#define IS_IOS8_LATER   ([UIDevice currentDevice].systemVersion.floatValue > 7.99)

#pragma mark - 颜色值设定

#define VIEW_BACK_COLOR [UIColor colorWithRed:244.0 / 255.0 green:244.0 / 255.0 blue:244.0 / 255.0 alpha:1.0]
#define VIEW_BORDER_COLOR [UIColor colorWithRed:218.0 / 255.0 green:218.0 / 255.0 blue:218.0 / 255.0 alpha:1.0]

// 系统色
#define COLOR_FOOT_LINE [UIColor lightGrayColor] // 浅灰色
#define COLOR_FOOT_BLACK [UIColor blackColor] // 黑色

// RGB
#define COLOR_RGBA_BLACK [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] // 黑色

#define COLOR_RGBA_BLACK_SET(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/1.0f] // 设置黑色

// 16进制色值
#define COLOR_16HEX_LIGHT_BLUE_SET(HEXValue) [UIColor colorWithRed:((float)((HEXValue & 0xFFFFFF) >> 16))/255.0 green:((float)((HEXValue & 0xFFFF) >> 8))/255.0 blue:((float)(HEXValue & 0xFF))/255.0 alpha:1.0] // 设置浅蓝色
#define COLOR_16HEX_LIGHT_BLUE COLOR_16HEX_LIGHT_BLUE_SET(0xCCFFFF) // 浅蓝色

#pragma mark - 字体大小设定

// 常规字
#define FONT_SIZE_14 [UIFont systemFontOfSize:14]

// 粗体字
#define FONT_BOLD_SIZE_14 [UIFont boldSystemFontOfSize:14]

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

// 字号
// 常规字
#define FONT_SIZE_36 [UIFont systemFontOfSize:36]
#define FONT_SIZE_30 [UIFont systemFontOfSize:30]
#define FONT_SIZE_24 [UIFont systemFontOfSize:24]
#define FONT_SIZE_20 [UIFont systemFontOfSize:20]
#define FONT_SIZE_18 [UIFont systemFontOfSize:18]
#define FONT_SIZE_15 [UIFont systemFontOfSize:15]
#define FONT_SIZE_14 [UIFont systemFontOfSize:14]
#define FONT_SIZE_13 [UIFont systemFontOfSize:13]
#define FONT_SIZE_10 [UIFont systemFontOfSize:10]

// 粗体字
#define FONT_BOLD_SIZE_36 [UIFont boldSystemFontOfSize:36]
#define FONT_BOLD_SIZE_30 [UIFont boldSystemFontOfSize:30]
#define FONT_BOLD_SIZE_24 [UIFont boldSystemFontOfSize:24]
#define FONT_BOLD_SIZE_20 [UIFont boldSystemFontOfSize:20]
#define FONT_BOLD_SIZE_18 [UIFont boldSystemFontOfSize:18]

#pragma mark - =====字体对齐======
// 首页对齐
#define HOME_TEXT_LEFT   NSTextAlignmentLeft    // 居左
#define HOME_TEXT_CENTER NSTextAlignmentCenter  // 居中
#define HOME_TEXT_RIGHT  NSTextAlignmentRight   // 居右

#pragma mark - 枚举
// core data entity 枚举
typedef NS_ENUM(NSUInteger, ICFCCoreDataValueType)
{
    ICFCAECAddressBookEntity = 0,
};

#pragma mark - DLog
//#undef  DEBUG
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define PUSH_PARAMETER @"develop"
//小西key
#define APP_KEY_LITTLEC_AND @"060018pr"

#else
#define DLog(...)
#define PUSH_PARAMETER @"product"
//小西key
#define APP_KEY_LITTLEC_AND @"114200ab"

#endif

#pragma mark - Text
#define IS_NULL(string) (!string || [string isEqual: @""] || [string isEqual:[NSNull null]])

// ===================== error code =====================
#define CODE_OK 200
#define CODE_ABSENT 0
#define VALIEDCODE_FAILED -16
#define PASSWORD_INVALIED -14
#define TIMEOUT_INVALIED 404
#define VALIEDCODE_USED -17
// ===================== Key ===============
#define USER_INFO @"userInfo"
#define USER_ONCE @"userOnce"
#define UPDATA_TIME @"upDataTime"
#define INFORM_DRAFT @"informDraft"

//----------------notify  //add by xu
#define kLoginSuccessNotify @"kLoginSuccessNotify"
#define kLoginOtherNotify @"kLoginOtherNotify"
#define kLoginFailNotify @"kLoginFailNotify"
#define kUSER_ACCOUNT @"AEC_USER_ACCOUNT"
#define kUSER_PASSWORD @"AEC_USER_PASSWORD"
#if !AddressBookChange
#define kUSER_CONNECT_LIST @"USER_CONNECT_LIST"
#endif
#define kUSER_XMPP_NONE_NOTIFY_FLAG @"kuser_xmpp_none_notify_flag"
#define REFRESH_NOTICE_LIST @"refresh_notice_list"
#define REFRESH_HOMEWORK_LIST @"refresh_homework_list"

#define HIDE_STATUS_BAR_VIEW @"hide_status_view"
#define SHOW_STATUS_BAR_VIEW @"show_status_view"

#define kNotificationCenter @"kNotificationCenter"
#define kREFRESH_EXAM_LIST @"krefresh_exam_list"


#define kSelectionLabKey        @"selectionLabKey"
#define kSelectionImageKey      @"selectionOImageKey"

#endif
