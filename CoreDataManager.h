//
//  CoreDataManager.h
//  testProject
//
//  Created by 猪猪 on 15/8/14.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, MY_coredataType)
{
    daliy_entity = 0
};
@interface CoreDataManager : NSObject
@property (strong, nonatomic, readonly) NSManagedObjectModel *managerObjectMode;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managerObjectContext;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
//增加
- (void)insertData:(NSMutableArray *)dataArr withType:(MY_coredataType )type;
//删除
- (void)deleteDatawithType:(MY_coredataType )type;
//查询
- (NSMutableArray*)selectData:(int)pageSize andOffset:(int)currentPage withType:(MY_coredataType)type;
//更新
- (void)updateData:(NSString*)newsId withIsLook:(NSString*)islook withType:(MY_coredataType)type;@end
