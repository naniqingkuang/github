//
//  CoreDataManager.m
//  testProject
//
//  Created by 猪猪 on 15/8/14.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager
@synthesize managerObjectMode = _managerObjectMode;
@synthesize managerObjectContext = _managerObjectContext;
@synthesize coordinator = _coordinator;

- (NSManagedObjectContext *)managerObjectContext
{
    if(_managerObjectContext)
    {
        return _managerObjectContext;
    }
    if(self.coordinator)
    {
        _managerObjectContext = [[NSManagedObjectContext alloc]init];
        [_managerObjectContext setPersistentStoreCoordinator:self.coordinator];
    }
    return _managerObjectContext;
}
- (NSManagedObjectModel *)managerObjectMode
{
    if (_managerObjectMode !=nil) {
        return _managerObjectMode;
    }
    NSURL *modelURL = [[NSBundle mainBundle]URLForResource:@"AndEducationClient" withExtension:@"momd"];
    _managerObjectMode = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    return _managerObjectMode;
}
- (NSPersistentStoreCoordinator *)coordinator
{
    if(_coordinator)
    {
        return _coordinator;
    }
    _coordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.managerObjectMode];
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO);
    NSString *str = [arr lastObject];
    
    NSURL *url = [NSURL URLWithString:[str stringByAppendingString:@"/mySqite.db"]];
   if(! [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:nil ])
   {
       NSLog(@"addPersistentStoreWithType err ");
   }
    return _coordinator;
}

#pragma mark 增删改查
- (void)insertData:(NSMutableArray *)dataArr withType:(MY_coredataType)type
{
    NSManagedObjectContext *context = [self managerObjectContext];
    switch (type) {
        case daliy_entity:
            [NSEntityDescription insertNewObjectForEntityForName:@"daily" inManagedObjectContext:context];
            break;
            
        default:
            break;
    }
}
- (void)deleteDatawithType:(MY_coredataType)type
{
    
}
- (void)updateData:(NSString *)newsId withIsLook:(NSString *)islook withType:(MY_coredataType)type
{
    
}

- (NSMutableArray *)selectData:(int)pageSize andOffset:(int)currentPage withType:(MY_coredataType)type
{
    NSManagedObjectContext *context = [self managerObjectContext];
    NSFetchRequest *fetchReq= [[NSFetchRequest alloc]init];
    [fetchReq setFetchLimit:pageSize];
    [fetchReq setFetchOffset:currentPage];
    if(context)
    {
        switch (type) {
            case daliy_entity:
                
                [context executeFetchRequest:fetchReq error:nil];
                break;
                
            default:
                break;
        }
    }
    return nil;
}
@end
