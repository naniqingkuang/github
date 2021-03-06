 //
//  ModifyViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/9.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "ModifyViewController.h"
#import "SliderViewController.h"
@interface ModifyViewController ()

@end

#import "TableViewCell1.h"
#import "TableViewCell2.h"
#import "UserUtil.h"
#import "MBProgressHUD+Util.h"
#import "RequestUtil.h"
#import "BlueToothUtil.h"
#define Titles  @"用户",@"真实姓名",@"性别",@"用户类型",@"出生日期",@"身高",@"体重",@"住址",@"手机号",@"邮箱"
#define USER_TYPE @"心梗的人",@"脑卒中的人",@"下肢骨折的人",@"下肢关节的人",@"减肥的人",@"伏案工作的人",@"青少年成长的人",@"正常人和亚健康人群"
#define USER_GENDER @"男",@"女"
#define USER_TYPE_DICT @"心梗的人":@"1",@"脑卒中的人":@"2",@"下肢骨折的人":@"3",@"下肢关节的人":@"4",@"减肥的人":@"5",@"伏案工作的人":@"6",@"青少年成长的人":@"7",@"正常人和亚健康人群":@"8"

@interface ModifyViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, strong) NSMutableArray *pickerViewArr;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerBackgroundView;
@property (nonatomic, strong) NSIndexPath *currentPath;
@property (nonatomic, strong) UITextField *curText;
@property (nonatomic, strong) UserUtil *registerUser;
@property (nonatomic, strong) NSMutableArray *dataDest;
@property (nonatomic, strong) NSDictionary *userTypeDict;
@end

@implementation ModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setup];
    // Do any additional setup after loading the view from its nib.
}
- (void)setup
{
    self.pickerView.hidden = YES;
    self.datePickerBackgroundView.hidden = YES;
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
    [self.tableView reloadData];
}
- (void)initData
{
    self.titleList = @[Titles];
    self.registerUser = [RequestUtil getCurrentUser];
    self.registerUser.password32 = @"******";
    self.dataDest = [[NSMutableArray alloc]initWithObjects:self.registerUser.userName32,
                     self.registerUser.realName32,
                     self.registerUser.gender1,
                     self.registerUser.userType1,
                     self.registerUser.birthday8,
                     self.registerUser.height,
                     self.registerUser.weight,
                     self.registerUser.address256,
                     self.registerUser.phone32,
                     self.registerUser.email32, nil];
    self.userTypeDict = @{USER_TYPE_DICT};
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleList.count;
}
- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return 1;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //cell.contentText.text = @"";
    NSString *title = self.titleList[indexPath.row];
    if([title isEqualToString:@"性别"] || [title isEqualToString:@"用户类型"] || [title isEqualToString:@"出生日期"])
    {
        NSString *myCellId = @"RegisterTableViewCell2";
        TableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:myCellId];
        if(!cell)
        {
            cell = (TableViewCell2 *)[[[NSBundle mainBundle]loadNibNamed:@"TableViewCell2" owner:self options:nil]lastObject];
        }
        NSString *str = nil;
        if([title isEqualToString:@"性别"]) {
            str = [self.dataDest[indexPath.row] isEqualToString:@"0"] ? @"男" : @"女";
        }
        if([title isEqualToString:@"用户类型"]) {
            NSArray *arr = [self.userTypeDict allKeys];
            for (NSString *item in arr) {
                if([self.userTypeDict[item] isEqualToString:self.registerUser.userType1]){
                    str = item;
                }
            }
        }
        if([title isEqualToString:@"出生日期"]){
            str = self.registerUser.birthday8;
            if(str && str.length == 8) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"YYYYMMDD"];
                NSDate *date = [dateFormatter dateFromString:str];
                [dateFormatter setDateFormat:@"YYYY-MM-DD"];
                str = [dateFormatter stringFromDate:date];
            }
        }
        
        cell.titleLB.text = title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentLB.tag = indexPath.row;
        cell.contentLB.text = str;
        return cell;
    }
    else
    {
        NSString *myCellId = @"RegisterTableViewCell1";
        TableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:myCellId];
        if(!cell)
        {
            cell = (TableViewCell1 *)[[[NSBundle mainBundle]loadNibNamed:@"TableViewCell1" owner:self options:nil]lastObject];
        }
        cell.titleLB.text = title;
        cell.contentText.delegate = self;
       // cell.contentText.text = self.dataDest[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentText.tag = indexPath.row;
//        if(indexPath.row == 5) {
//            cell.contentText.text =[NSString stringWithFormat:@"%ld",[self.dataDest[indexPath.row]integerValue]];
//        } else {
            cell.contentText.text = self.dataDest[indexPath.row];

//        }
        return cell;
        
    }
    return nil;
}
- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(indexPath.row == 2)
    {
        if(self.curText)
        {
            [self.curText resignFirstResponder];
        }
        [self pickSexItem];
    }
    if(indexPath.row == 3)
    {
        if(self.curText)
        {
            [self.curText resignFirstResponder];
        }
        [self pickUserType];
    }
    if(indexPath.row == 4)
    {
        if(self.curText)
        {
            [self.curText resignFirstResponder];
        }
        [self pickDate];
    }
}
- (void)pickSexItem
{
    self.pickerView.hidden = NO;
    self.datePickerBackgroundView.hidden = YES;
    self.pickerViewArr = [[NSMutableArray alloc]initWithObjects:USER_GENDER,nil];
    [self.pickerView reloadAllComponents];
    self.currentPath = [NSIndexPath indexPathForRow:2 inSection:0];
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    cell.contentLB.text = @"";
    
}

- (void)pickUserType
{
    self.pickerView.hidden = NO;
    self.datePickerBackgroundView.hidden = YES;
    self.pickerViewArr = [[NSMutableArray alloc]initWithObjects:USER_TYPE,nil];
    [self.pickerView reloadAllComponents];
    self.currentPath = [NSIndexPath indexPathForRow:3 inSection:0];
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    cell.contentLB.text = @"";
}
- (void)pickDate
{
    self.pickerView.hidden = YES;
    self.datePickerBackgroundView.hidden = NO;
    self.currentPath = [NSIndexPath indexPathForRow:4 inSection:0];
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    cell.contentLB.text = @"";
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark UIPickerView delegate and datasource
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerViewArr.count;
}
- (nullable NSString *)pickerView:(nonnull UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = self.pickerViewArr[row];
    return str;
}
- (void)pickerView:(nonnull UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    NSString *title = self.pickerViewArr[row];
    [self.dataDest replaceObjectAtIndex:self.currentPath.row withObject:title];
    cell.contentLB.text = title;
    self.pickerView.hidden = YES;
}
- (IBAction)returnButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)datePickerConfirmButtonClicked:(id)sender {
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    cell.contentLB.text = [formatter stringFromDate:self.datePicker.date];
    self.datePickerBackgroundView.hidden = YES;
    [self.dataDest replaceObjectAtIndex:self.currentPath.row withObject:cell.contentLB.text];
}
- (IBAction)datePickerCancelButtonClicked:(id)sender {
    self.datePickerBackgroundView.hidden = YES;
    TableViewCell1 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    cell.contentText.enabled = YES;
}
- (void)textFieldDidEndEditing:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(nonnull UITextField *)textField
{
    self.curText = textField;
    self.pickerView.hidden = YES;
    self.datePickerBackgroundView.hidden = YES;
}
- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
    self.pickerView.hidden = YES;
    self.datePickerBackgroundView.hidden = YES;
    return YES;
}
- (void)getDataFromCell
{
    self.registerUser.userName32 = self.dataDest[0];
    self.registerUser.realName32 = self.dataDest[1];
    self.registerUser.gender1 =  [self.dataDest[2] isEqual:@"男" ]? @"1" : @"2";
    self.registerUser.userType1 = self.userTypeDict[(self.dataDest[3])];
    self.registerUser.birthday8 = self.dataDest[4];
    self.registerUser.height = self.dataDest[5];
    self.registerUser.weight = self.dataDest[6];
    self.registerUser.address256 = self.dataDest[7];
    self.registerUser.phone32 = self.dataDest[8];
    self.registerUser.email32 = self.dataDest[9];
    [[BlueToothUtil getBlueToothInstance]readDeviceID:^(NSString *name) {
        self.registerUser.deviceID18 = name;
    }];
    if(!self.registerUser.deviceID18)
    {
        self.registerUser.deviceID18 = @"YDNNN2015090600012";
    }
    self.registerUser.clientid2_32 = @"0e0d6ec90fae2ebf1a96f661439c0dfc";
    NSDateFormatter *formmater = [[NSDateFormatter alloc]init];
    [formmater setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    self.registerUser.registerdate14 = [formmater stringFromDate:[NSDate date]];
    NSString *err = [self.registerUser checkType];
    if(err.length >0)
    {
        [MBProgressHUD showError:err];
    }
}
- (NSString *)getResultFromTextFeild:(NSInteger )row section:(NSInteger ) section
{
    NSString *res = nil;
    NSIndexPath *path = [NSIndexPath indexPathForItem:row inSection:section];
    if(row >=2  && row <= 4)
    {
        TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:path];
        res = cell.contentLB.text;
    }
    else
    {
        TableViewCell1 *cell = [self.tableView cellForRowAtIndexPath:path];
        res = cell.contentText.text;
    }
    return res;
}
- (IBAction)backButtonClicked:(id)sender {
    [[SliderViewController sharedSliderController]leftItemClickToMain];
}
- (IBAction)updateCommit:(id)sender {
    [self getDataFromCell];
    [[BlueToothUtil getBlueToothInstance]readDeviceID:^(NSString *name) {
        self.registerUser.deviceID18 = name;
    }];
    [self.registerUser checkAndAvoidNull];
    [RequestUtil userUpdateInfo:self.registerUser block:^(bool flag) {
        if (flag) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [MBProgressHUD showError:@"修改成功"];
            [RequestUtil setCurrentUser:self.registerUser];
        }
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.dataDest replaceObjectAtIndex:textField.tag withObject:textField.text];
    for (int i = 0; i < self.dataDest.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
        TableViewCell1 *cell = [self.tableView cellForRowAtIndexPath:path];
        if([cell respondsToSelector:@selector(contentText)]){
            if(textField == cell.contentText && i > 6) {
                [self keboardHide:i];
            }
        }
    }

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    for (int i = 0; i < self.dataDest.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
        TableViewCell1 *cell = [self.tableView cellForRowAtIndexPath:path];
        if([cell respondsToSelector:@selector(contentText)]){
            if(textField == cell.contentText && i > 6) {
                [self keboardShow:i];
            }
        }
    }
    
    return YES;
}
- (void)keboardShow:(int )num {
//    CGRect frame = self.view.frame;
//    frame.origin.y -= 150;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:0.2];
//    self.view.frame = frame;
//    [UIView commitAnimations];
}
- (void)keboardHide:(int )num{
//    CGRect frame = self.view.frame;
//    frame.origin.y +=  150;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:0.2];
//    self.view.frame = frame;
//    [UIView commitAnimations];
}

@end
