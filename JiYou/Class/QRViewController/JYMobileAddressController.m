//
//  JYMobileAddressController.m
//  EmailDemo
//
//  Created by 俊王 on 15/12/21.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYMobileAddressController.h"

#import "UIColor+Additions.h"
#import "UIImage+Additions.h"
#import "JYDepartmentTableViewCell.h"
#import "JYContentTableViewCell.h"
#import "JYDepartmentViewController.h"
#import "JYMobileAddressModel.h"
#import "JYMobileDetailModel.h"
#import "pinyin.h"
#import "JYMobileDetailViewController.h"
#import "JYPromptTipsCell.h"
#import "BKLineView.h"
#import "NSString+Additions.h"

#define kSearched @"searched"

@interface JYMobileAddressController ()<UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSMutableArray *mobieModelList;

@property (nonatomic, strong) NSArray * keys; //分组组号
@property (nonatomic, strong) NSMutableArray* data;  //不分组的所有数据
@property (nonatomic, strong) NSMutableArray* searchedData; //所有的手机号
@property (nonatomic, strong) NSMutableArray* filteredData; //过滤后的不分组所有数据
@property (nonatomic, strong) NSMutableDictionary* filteredDataDic;

@property (nonatomic, strong) NSMutableArray *sortArray;

@property (nonatomic, strong) NSMutableArray *searchSortedArray;

@property (nonatomic, strong) NSMutableDictionary *sortDic;

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) JYMobileAddressModel *mobileModel;

@property (nonatomic, strong) UILabel *totalLabel;

@property (nonatomic, strong) BKHorizontalLineView *lineView;

@end

@implementation JYMobileAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.keys = [NSArray array];
    self.data = [NSMutableArray array];
    self.filteredData = [NSMutableArray array];
    self.sortArray = [NSMutableArray array];
    self.searchedData = [NSMutableArray array];
    self.filteredDataDic = [NSMutableDictionary dictionary];
    self.sortDic = [NSMutableDictionary dictionary];
    self.searchSortedArray = [NSMutableArray array];
    
    self.dataList = [[NSMutableArray alloc] initWithCapacity:0];
    self.mobieModelList = [[NSMutableArray alloc] initWithCapacity:0];
    self.mobileModel = [[JYMobileAddressModel alloc] init];
    
    self.navTitle = @"通讯录";

    self.view.backgroundColor = [UIColor colorWithHexString:@"0xEAEAEA"];
    
//    38AEE7
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchBar.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, 44.0);
    _searchController.searchBar.placeholder = @"姓名或手机号";
    [self.searchController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xf0eff5 alpha:1.0]]
                        forBarPosition:UIBarPositionTop
                            barMetrics:UIBarMetricsDefault];
    [self.searchController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHex:0xeeeeee alpha:1.0]]
                        forBarPosition:UIBarPositionTopAttached
                            barMetrics:UIBarMetricsDefault];
    self.definesPresentationContext = YES;
    [self.view addSubview:self.searchController.searchBar];
    
    self.searchController.searchBar.alpha = 0;

    for (UIView *view in [self.searchController.searchBar subviews]) {
        NSLog(@"%@",[[view class] description]);
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *cancel = (UIButton *)view;
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            [cancel setTitleColor:[UIColor colorWithHexString:@"0x38AEE7"] forState:UIControlStateNormal];
        }
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + 44, kScreenWidth, kScreenHeight - kNavigationBarHeight - 44) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYDepartmentTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYDepartmentTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYContentTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYContentTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYPromptTipsCell class]) bundle:nil] forCellReuseIdentifier:@"JYPromptTipsCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"JYMobileAddressCell"];
    
    self.tableView.sectionIndexColor = [UIColor colorWithHex:0x18A7E6 alpha:1.0];
    self.tableView.sectionIndexTrackingBackgroundColor = self.view.backgroundColor;
    
    self.tableView.alpha = 0;
    
    if ([self.tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)])
    {
        [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    }
    
    [self getPersonImformation];
    
    if (self.sortDic.count > 0)
    {
        self.keys = [[self.sortDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString * s1 = obj1;
            NSString * s2 = obj2;
            return [s1 compare:s2];
        }];
        
        for (NSString* key in self.keys) {
            [self.data addObjectsFromArray:[self.sortDic objectForKey:key]];
        }
        
        [self.tableView reloadData];
    }
    
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    _lineView = [[BKHorizontalLineView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"0xbbbbbb"];
    [footerView addSubview:_lineView];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 25)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    self.totalLabel = label;
    [footerView addSubview:label];
    self.tableView.tableFooterView = footerView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.searchController.active) {
        
        self.navigationController.navigationBarHidden = YES;
        self.navigationBarHidden = YES;
    }
    else{
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [self getUserPlistData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.searchController.searchBar resignFirstResponder];
}

#pragma mark
#pragma mark SearchedData Store and Check
-(NSString *)getSearchDataFilePath
{
    //获取本地沙盒路径
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取完整路径
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"usersList.plist"];
    
    return plistPath;
}

/// 添加数据
-(void)storeSearchedDataWithDetailModel:(JYMobileDetailModel *)detailMode
{
    
    NSString *plistPath = [self getSearchDataFilePath];
    
    NSMutableDictionary *usersDic = [[NSMutableDictionary alloc] init];
    
    //设置属性值,没有的数据就新建，已有的数据就修改。
    [usersDic setObject:detailMode.name forKey:@"name"];
    [usersDic setObject:detailMode.mobile forKey:@"mobile"];
    [usersDic setObject:detailMode.preEmail forKey:@"email"];
    [usersDic setObject:detailMode.telePhone forKey:@"telephone_number"];
    [usersDic setObject:detailMode.departmentName forKey:@"department_name"];
    [usersDic setObject:detailMode.parentDepartmentName forKey:@"parent_department_name"];
    if (NSString_ISNULL(detailMode.headURL)) {
        
        detailMode.headURL = @"";
    }
    [usersDic setObject:detailMode.headURL forKey:@"head_url"];
    [usersDic setObject:detailMode.extension forKey:@"extension"];
    if (NSString_ISNULL(detailMode.title)) {
        
        detailMode.title = @"";
    }
    [usersDic setObject:detailMode.title forKey:@"emp_position"];

    if (self.searchedData.count > 4) {
        
        [self.searchedData removeObjectAtIndex:0];
    }
    
    [self.searchedData addObject:usersDic];
    //写入文件
    [self.searchedData writeToFile:plistPath atomically:YES];
    
    [self getUserPlistData];
}

-(void)clearAllSearchedData:(id)sender{
    
    NSString *filePath = [self getSearchDataFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    [self.searchedData removeAllObjects];
    [self.searchSortedArray removeAllObjects];
    [self.tableView reloadData];
}

/// 数据删除
-(void)removeSearchedDetailModelWithIndex:(NSInteger)index{
    
    [self.searchedData removeObjectAtIndex:(self.searchedData.count - index - 1)];
    
    NSString *plistPath = [self getSearchDataFilePath];
    //写入文件
    [self.searchedData writeToFile:plistPath atomically:YES];
    [self getUserPlistData];
}

-(void)getUserPlistData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.searchedData removeAllObjects];
        [self.searchSortedArray removeAllObjects];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[self getSearchDataFilePath]]) {
            NSArray *fileArray = [[NSArray alloc] initWithContentsOfFile:[self getSearchDataFilePath]];
            [self.searchedData addObjectsFromArray:fileArray];
        }
        
        NSInteger count = self.searchedData.count;
        for (NSInteger i = count - 1; i >= 0; i--) {
            [self.searchSortedArray addObject:self.searchedData[i]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark
#pragma mark SearchControler Methods

-(void)willPresentSearchController:(UISearchController *)searchController
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    self.navigationController.navigationBarHidden = YES;
    self.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf0eff5"];

    self.view.frame = CGRectMake(0, 20, kScreenWidth, kScreenHeight - 20);
    
    [UIView animateWithDuration:0.25 animations:^{

        self.searchController.searchBar.frame = CGRectMake(0, 7, kScreenWidth, 44);
        self.tableView.frame = CGRectMake(0, kNavigationBarHeight - 6, kScreenWidth, kScreenHeight - kNavigationBarHeight + 6);
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)didDismissSearchController:(UISearchController *)searchController
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    self.navigationController.navigationBarHidden = NO;
    self.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xEAEAEA"];

    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeight);
        self.searchController.searchBar.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, 44);
        self.tableView.frame = CGRectMake(0, kNavigationBarHeight + 44, kScreenWidth, kScreenHeight - kNavigationBarHeight - 44);
        
    } completion:^(BOOL finished) {
        
    }];

    NSString *searchStr = self.searchController.searchBar.text;
    [self filterContentForSearchText:searchStr];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchStr = self.searchController.searchBar.text;
    [self filterContentForSearchText:searchStr];
}

#pragma mark 
#pragma mark - GetInformation

-(void)getPersonImformation
{
    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/contacts/contacts"
                                              params:nil
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     [self handleModileAddressModel:response.responseObject];
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
    
}

-(void)handleModileAddressModel:(NSDictionary *)modelString
{
    self.mobileModel.departDic= modelString[@"depart"];
    self.mobileModel.departName = modelString[@"departName"];
    self.mobileModel.departEmpNum = modelString[@"departEmpNum"];
    self.mobileModel.departDetailDic = modelString[@"departDetail"];
    
    NSLog(@"%@",self.mobileModel.departName);
    
    for (NSString *key in [self.mobileModel.departName allKeys]) {
        
        [self.dataList addObjectsFromArray:[self.mobileModel.departDetailDic objectForKey:key]];
    }
    
    for (NSDictionary *dic in self.dataList) {
        
        JYMobileDetailModel *model = [[JYMobileDetailModel alloc] initWithDataDic:dic];
        [self.mobieModelList addObject:model];
        [self handleAddressItem:model];
    }
    
    __block JYMobileAddressController *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        weakself.keys = [[weakself.sortDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString * s1 = obj1;
            NSString * s2 = obj2;
            return [s1 compare:s2];
        }];
        
        for (NSString *key in weakself.keys) {
            NSArray *valueArray = [weakself.sortDic objectForKey:key];
            [weakself.sortDic setObject:[weakself sortArrayWithNumericSearchWithArray:valueArray] forKey:key];
            /// 全部数据排序
            [weakself.data addObjectsFromArray:[weakself sortArrayWithNumericSearchWithArray:valueArray]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!self.searchController.active) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
            
            [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
            weakself.tableView.alpha = 1;
            weakself.searchController.searchBar.alpha = 1;
            [weakself.tableView reloadData];
        });
    });
}


/// 数据按照自然顺序排序
-(NSMutableArray *)sortArrayWithNumericSearchWithArray:(NSArray *)array{
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    ///数据进行自然数字排序
    for (JYMobileDetailModel *detailModel in array) {
        
        NSString *nameString = [[self firstCharactor:detailModel.name] formatFromBankCard];
        [dataDic setObject:detailModel forKey:[nameString stringByAppendingString:detailModel.mobile]];
    }
    
    /// 按照自然排好序后个人信息key数组
    NSArray *keyArray = [[dataDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSString *key1 = obj1;
        NSString *key2 = obj2;
        return [key1 compare:key2 options:NSNumericSearch];
        
    }];
    
    /// 按照自然排好序后个人信息key对应的数据
    for (NSString *key in keyArray) {
        
        [dataArray addObject:[dataDic objectForKey:key]];
    }
    
    return dataArray;
}

- (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
//    NSString *pinYin = [str uppercaseString];
    //获取并返回首字母
    return [str lowercaseString];
}

- (void)handleAddressItem:(JYMobileDetailModel *)item
{
    NSString * firstChar = @"";
    NSString * name = item.name;
    NSString * mobile = item.mobile;
    NSString * regex = @"^[A-Za-z].*";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];

    if (name.length == 0)
    {
        firstChar = @"#";
    }
    else if ([predicate evaluateWithObject:name])
    {
        firstChar = [[name substringToIndex:1] uppercaseString];
    }
    else
    {
        firstChar = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([name characterAtIndex:0])] uppercaseString];
    }
    
    if ([self.sortDic objectForKey:firstChar] && [[self.sortDic objectForKey:firstChar] isKindOfClass:[NSMutableArray class]])
    {
        NSInteger duplicateCount = 0;
        NSMutableArray * list = (NSMutableArray *)[self.sortDic objectForKey:firstChar];
        for (JYMobileDetailModel * item in list) {
            
            if ([item.mobile isEqualToString:mobile]) { //如果电话号码重复 那么去掉重复的item
                duplicateCount++;
            }
        }
        if (duplicateCount == 0) {
            [list addObject:item];
        }
    }
    else
    {
        NSMutableArray * list = [NSMutableArray array];
        [list addObject:item];
        [self.sortDic setObject:list forKey:firstChar];
    }
}

- (NSString *)removeSpecialCharacter: (NSString *)str
{
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"-,.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
    if (urgentRange.location != NSNotFound)
    {
        return [self removeSpecialCharacter:[str stringByReplacingCharactersInRange:urgentRange withString:@""]];
    }
    return str;
}

//源字符串内容是否包含或等于要搜索的字符串内容
-(void)filterContentForSearchText:(NSString*)searchText
{
    NSMutableArray *tempResults = [NSMutableArray array];
    NSMutableArray *secondResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (JYMobileDetailModel *detailModel in self.data) {
        
        NSString *nameString = detailModel.name; //按姓名查找
        NSString *mobileString = detailModel.mobile; //按手机号查找
        NSString *namePingString = detailModel.nameSpell;// 按照姓名拼音来查找
        
        NSRange nameRange = NSMakeRange(0, nameString.length);
        NSRange mobileRange = NSMakeRange(0, mobileString.length);
        NSRange namePingRange = NSMakeRange(0, namePingString.length);
        
        NSRange foundNameRange = [nameString rangeOfString:searchText options:searchOptions range:nameRange];
        NSRange foundMobileRange = [mobileString rangeOfString:searchText options:searchOptions range:mobileRange];
        NSRange foundNamePingRange = [namePingString rangeOfString:searchText options:searchOptions range:namePingRange];
        
        if (foundNameRange.length || foundMobileRange.length || foundNamePingRange.length) {
            
            if (foundNameRange.location == 0 || foundMobileRange.location == 0 || foundNamePingRange.location == 0) {
                
                [tempResults addObject:detailModel];
            }
            else{
                
                [secondResults addObject:detailModel];
            }
        }
    }
    
    if (secondResults.count > 0) {
        
        [tempResults addObjectsFromArray:secondResults];
    }
    
    [self.filteredData removeAllObjects];
    [self.filteredData addObjectsFromArray:tempResults];
    
    [self.tableView reloadData];
}


#pragma mark
#pragma mark TableViewDelegate And TableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) { //如果是搜索结果
        
        if (NSString_ISNULL(self.searchController.searchBar.text)) {
            
            if(self.searchSortedArray.count > 0){
                
                return self.searchSortedArray.count;
            }
        }
        else{
            
            if (self.filteredData.count > 0) {
                return self.filteredData.count;
            }
        }
        
        return 1;
        
    } else {
    
        if (self.keys.count > 0) {
            if (section == 0) {
                return 1;
            } else {
                NSMutableArray * array = [self.sortDic objectForKey:[self.keys objectAtIndex:section-1]];
                return array.count;
            }
        } else {
            return 1;
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active) { //如果是搜索结果, 那么只显示一个section
        
        return 1;
        
    } else {
        
        if (self.keys.count > 0) {
            return self.keys.count + 1; //这里的1 是邀请新朋友cell + 通讯录Title cell
        }
        return 1;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active) {
        
        if (self.searchController.searchBar.text.length > 0) {
            
            if (self.filteredData.count > 0) {
                
                return 70;
            }
            else{
                
                return 100;
            }
        }
        else
        {
            if(self.searchSortedArray.count > 0){
                
                return 50;
            }
            else{
                
                return 100;
            }
        }
    }
    else{
        
        if (indexPath.section == 0) {
            
            return 60;
        }
        else{
            
            return 70;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active && !self.searchController.searchBar.text.length) {
    
        if (self.searchSortedArray.count > 0) {
         
            return 50.0f;
        }
    }
    else{
        if (section == 0) {
            
            return CGFLOAT_MIN;
        }
        else{
            
            return 25.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!self.searchController.searchBar.text.length && self.searchController.active) {
        if (self.searchSortedArray.count > 0) {
            return 60;
        }
    }
    
    return CGFLOAT_MIN;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return 0;
    } else {
        
        if (self.keys.count > 0) {
            NSMutableArray* titles = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
            [titles addObjectsFromArray:self.keys];
            return titles;
        } else {
            return nil;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [self.tableView scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
        return NSNotFound;
    } else {
        
        [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:title];
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active) {
        
        if (NSString_ISNULL(self.searchController.searchBar.text) && self.searchSortedArray.count > 0) {
            
            UIView * view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            _lineView = [[BKHorizontalLineView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
            _lineView.backgroundColor = [UIColor colorWithHexString:@"0xbbbbbb"];
            [view addSubview:_lineView];
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 300, 25)];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor colorWithHexString:@"0xADADAD"];
            label.text = @"最近搜索记录";
            [view addSubview:label];
            return view;
        }
        
    } else {
        
        if (self.keys.count > 0) {
            
            if (section != 0) {
                UIView * view = [[UIView alloc] init];
                view.backgroundColor = self.view.backgroundColor;
                UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 25)];
                label.font = [UIFont systemFontOfSize:16];
                label.text = [self.keys objectAtIndex:section -1];
                [view addSubview:label];
                return view;
            }
        }
    }
    
    return nil;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.searchController.active && NSString_ISNULL(self.searchController.searchBar.text)) {
        
        if (self.searchSortedArray.count > 0) {
            
            UIView * view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            
            BKHorizontalLineView *lineView = [[BKHorizontalLineView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
            lineView.backgroundColor = [UIColor colorWithHexString:@"0xbbbbbb"];
            [view addSubview:lineView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"清除搜索记录" forState:UIControlStateNormal];
            button.frame = CGRectMake(kScreenWidth/6, 0, 2*kScreenWidth/3, 60);
            [button addTarget:self action:@selector(clearAllSearchedData:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor colorWithHexString:@"0x38AEE7"] forState:UIControlStateNormal];
            
            [view addSubview:button];
            return view;
        }
    }
    
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    if (self.searchController.active) {
        
        self.totalLabel.text = @"";
        self.lineView.hidden = YES;

        tableView.backgroundColor = [UIColor whiteColor];
        
        /// 当searchBar.length >0 说明正在搜索中 否则是未搜索状态
        if (self.searchController.searchBar.text.length > 0) {
            
            if (self.filteredData.count > 0) {
                
                JYContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYContentTableViewCell"];
                cell.isSearched = YES;
                cell.searchedString = self.searchController.searchBar.text;
                JYMobileDetailModel * item = [self.filteredData objectAtIndex:indexPath.row];
                cell.detailModel = item;
                
                return cell;
                
            }
            else{
                
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                JYPromptTipsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYPromptTipsCell"];
                cell.nameLabel.text = @"无符合条件的记录";
                return cell;
            }
        }
        else {

            if (self.searchSortedArray.count > 0 ) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYMobileAddressCell"];
                JYMobileDetailModel *detailModel = [[JYMobileDetailModel alloc] initWithDataDic:self.searchSortedArray[indexPath.row]];
                
                cell.textLabel.text = detailModel.name;
                return cell;

            }
            else{
                
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                JYPromptTipsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYPromptTipsCell"];
                cell.nameLabel.text = @"暂无搜索记录";
                return cell;
            }
        }
    }
    else{
     
        if (self.keys.count > 0) {
            
            if (indexPath.section == 0) {
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYDepartmentTableViewCell"];
                cell.imageView.image = [UIImage imageNamed:@"department.png"];
                cell.textLabel.text = @"按部门查询";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            else{
                
                JYContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYContentTableViewCell"];
                cell.isSearched = NO;
                self.sortArray = [self.sortDic objectForKey:[self.keys objectAtIndex:indexPath.section - 1]];
                if (self.sortArray.count > 0) {
                    
                    JYMobileDetailModel * item = [self.sortArray objectAtIndex:indexPath.row];
                    cell.detailModel = item;
                    
                }
                else {
                    
                    cell.detailModel = nil;
                }
            
                self.lineView.hidden = NO;
                self.totalLabel.text = [NSString stringWithFormat:@"%ld 个联系人",(unsigned long)self.data.count];
                return cell;
            }
        }
        else{
            
            JYPromptTipsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYPromptTipsCell"];
            cell.nameLabel.text = @"无通讯录数据";
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            return cell;
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length > 0) {
            
            if (self.filteredData.count > 0) {
                
                JYMobileDetailModel * detailModel = nil;
                detailModel = (JYMobileDetailModel *)[self.filteredData objectAtIndex:indexPath.row];
                
                [self storeSearchedDataWithDetailModel:detailModel];
                
                JYMobileDetailViewController *mobileVC = [[JYMobileDetailViewController alloc] init];
                mobileVC.detailModel = detailModel;
                [self.navigationController pushViewController:mobileVC animated:YES];
            }
        }
        else{
            
            if (self.searchSortedArray.count > 0) {
                NSLog(@"---%@",self.searchSortedArray[indexPath.row]);
                JYMobileDetailModel *detailModel = [[JYMobileDetailModel alloc] initWithDataDic:self.searchSortedArray[indexPath.row]];
                JYMobileDetailViewController *mobileVC = [[JYMobileDetailViewController alloc] init];
                mobileVC.detailModel = detailModel;
                [self.navigationController pushViewController:mobileVC animated:YES];
            }
        }
    }
    else{
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            
            JYDepartmentViewController *departmentVC = [[JYDepartmentViewController alloc] init];
            departmentVC.mobileModel = self.mobileModel;
            [self.navigationController pushViewController:departmentVC animated:YES];
        
        }
        else{
            
            JYMobileDetailModel * detailModel = nil;
            NSArray *array = [self.sortDic objectForKey:[self.keys objectAtIndex:indexPath.section - 1]];

            if (array.count > 0) {
                detailModel = [array objectAtIndex:indexPath.row];
            }
            
            JYMobileDetailViewController *mobileVC = [[JYMobileDetailViewController alloc] init];
            mobileVC.detailModel = detailModel;
            [self.navigationController pushViewController:mobileVC animated:YES];
         
        }
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active && NSString_ISNULL(self.searchController.searchBar.text)) {
        
        if (self.searchSortedArray.count > 0) {
            
            return UITableViewCellEditingStyleDelete;

        }
    }
    
    return UITableViewCellEditingStyleNone;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active && NSString_ISNULL(self.searchController.searchBar.text)) {
        
        if (self.searchSortedArray.count > 0) {
            
            return @"删除";
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"%ld",indexPath.row);
        [self removeSearchedDetailModelWithIndex:indexPath.row];
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
