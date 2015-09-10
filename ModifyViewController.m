 //
//  ModifyViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/9.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "ModifyViewController.h"

@interface ModifyViewController ()

@end

#import "TableViewCell1.h"
#import "TableViewCell2.h"
#import "UserUtil.h"
#import "MBProgressHUD+Util.h"
#import "RequestUtil.h"
#define Titles  @"用户",@"密码",@"确认密码",@"真实姓名",@"性别",@"用户类型",@"出生日期",@"身高",@"体重",@"住址",@"手机号",@"邮箱"

@interface ModifyViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic, strong) NSMutableArray *pickerViewArr;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerBackgroundView;
@property (nonatomic, strong) NSIndexPath *currentPath;
@property (nonatomic, strong) UITextField *curText;
@property (nonatomic, strong) UserUtil *modifyUser;
@property (nonatomic, strong) NSDictionary *dataDic;

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
- (void)initData
{
    
    self.titleList = @[Titles];
    self.modifyUser = [RequestUtil getCurrentUser];
    self.dataDic = @{@"用户":self.modifyUser.userName32 ,@"密码":self.modifyUser.password32,@"确认密码":@"",@"真实姓名":self.modifyUser.realName32,@"性别":self.modifyUser.gender1,@"用户类型":self.modifyUser.userType1,@"出生日期": self.modifyUser.birthday8,@"身高":self.modifyUser.height,@"体重":self.modifyUser.weight,@"住址":self.modifyUser.address256,@"手机号":self.modifyUser.phone32,@"邮箱":self.modifyUser.email32};
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
    if([title isEqual:@"性别"] || [title isEqual:@"用户类型"] || [title isEqual:@"出生日期"])
    {
        NSString *myCellId = @"RegisterTableViewCell2";
        TableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:myCellId];
        if(!cell)
        {
            cell = (TableViewCell2 *)[[[NSBundle mainBundle]loadNibNamed:@"TableViewCell2" owner:self options:nil]lastObject];
        }
        cell.titleLB.text = title;
        cell.contentLB.text = self.dataDic[title];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        cell.contentText.text = self.dataDic[title];
        cell.contentText.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    return nil;
}
- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(indexPath.row == 4)
    {
        if(self.curText)
        {
            [self.curText resignFirstResponder];
        }
        [self pickSexItem];
    }
    if(indexPath.row == 5)
    {
        if(self.curText)
        {
            [self.curText resignFirstResponder];
        }
        [self pickUserType];
    }
    if(indexPath.row == 6)
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
    self.pickerViewArr = [[NSMutableArray alloc]initWithObjects:@"男",@"女",nil];
    [self.pickerView reloadAllComponents];
    self.currentPath = [NSIndexPath indexPathForRow:4 inSection:0];
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    cell.contentLB.text = @"";
}

- (void)pickUserType
{
    self.pickerView.hidden = NO;
    self.datePickerBackgroundView.hidden = YES;
    self.pickerViewArr = [[NSMutableArray alloc]initWithObjects:@"心梗的人",@"脑卒中的人",@"下肢骨折的人",@"下肢关节的人",@"减肥的人",@"伏案工作的人",@"青少年成长的人",@"正常人和亚健康人群",nil];
    [self.pickerView reloadAllComponents];
    self.currentPath = [NSIndexPath indexPathForRow:5 inSection:0];
    TableViewCell2 *cell = [self.tableView cellForRowAtIndexPath:self.currentPath];
    cell.contentLB.text = @"";
}
- (void)pickDate
{
    self.pickerView.hidden = YES;
    self.datePickerBackgroundView.hidden = NO;
    self.currentPath = [NSIndexPath indexPathForRow:6 inSection:0];
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
    self.modifyUser.userName32 = [self getResultFromTextFeild:0 section:0];
    self.modifyUser.password32 = [self getResultFromTextFeild:1 section:0];
    self.modifyUser.realName32 = [self getResultFromTextFeild:3 section:0];
    self.modifyUser.gender1 = [self getResultFromTextFeild:4 section:0];
    self.modifyUser.userType1 = [self getResultFromTextFeild:5 section:0];
    self.modifyUser.birthday8 = [self getResultFromTextFeild:6 section:0];
    self.modifyUser.height = [self getResultFromTextFeild:7 section:0];
    self.modifyUser.weight = [self getResultFromTextFeild:8 section:0];
    self.modifyUser.address256 = [self getResultFromTextFeild:9 section:0];
    self.modifyUser.phone32 = [self getResultFromTextFeild:10 section:0];
    self.modifyUser.email32 = [self getResultFromTextFeild:10 section:0];
    NSString *err = [self.modifyUser checkType];
    if(err.length >0)
    {
        [MBProgressHUD showError:err];
    }
}
- (NSString *)getResultFromTextFeild:(NSInteger )row section:(NSInteger ) section
{
    NSString *res = nil;
    NSIndexPath *path = [NSIndexPath indexPathForItem:row inSection:section];
    if(row >=4  && row <= 6)
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

@end
