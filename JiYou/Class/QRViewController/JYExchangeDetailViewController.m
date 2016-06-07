//
//  JYExchangeDetailViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/20.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYExchangeDetailViewController.h"
#import "JYMyExchangeTableViewCell.h"
#import "JYCustomView.h"
#import "SVPullToRefresh.h"
#import "JYMyExchangeModel.h"
#import "JYNetworkFailView.h"
#import "JYQRcodeViewController.h"

@interface JYExchangeDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (nonatomic, strong) UIView* tableViewHeaderView; //表头

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) JYMyExchangeModel *exchangeModel;

@property (nonatomic, strong) JYMyExchangeTableViewCell *exchangCell;

@end

@implementation JYExchangeDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navTitle = @"积分明细";
    
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:0];

    self.exchangeModel = [[JYMyExchangeModel alloc] init];

    self.currentPage = 1;
    
    self.contentTableView.hidden = YES;
    [self.contentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYMyExchangeTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYExchangeDetailTableViewCell"];
    
    self.contentTableView.rowHeight = 75;
    self.contentTableView.sectionHeaderHeight = 15;
    
    __weak JYExchangeDetailViewController *weakSelf = self;
    
    [self.contentTableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    [self.contentTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contentTableView triggerPullToRefresh];
}

- (void)insertRowAtTop{
    
    self.currentPage = 1;
    [self getMyExchangeDataForHeaderView:YES];
    
}

- (void)insertRowAtBottom{
    
    self.currentPage += 1;
    
    if (self.currentPage > [self.exchangeModel.countPage integerValue]) {
        
        if ([self.exchangeModel.countPage integerValue] < self.currentPage) {
            //替换footerView
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 52)];
            view.backgroundColor = [UIColor clearColor];
            
            UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 95, 52)];
            containerView.backgroundColor = [UIColor clearColor];
            containerView.center = view.center;
            [view addSubview:containerView];
            
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ark_icon_smile"]];
            imageView.frame = CGRectMake(0, 17, 15, 15);
            [containerView addSubview:imageView];
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 200, 52)];
            label.text = @"没有更多了";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:@"666666"];
            [label sizeToFit];
            label.left = imageView.right + 10;
            [containerView addSubview:label];
            
            _contentTableView.tableFooterView = view;
            _contentTableView.showsInfiniteScrolling = NO;
        }
        
    }
    else{
        
        [self getMyExchangeDataForHeaderView:NO];
    }
}


-(void)getMyExchangeDataForHeaderView:(BOOL)isHeader{
    
    NSDictionary* params = @{@"currentPage":[NSString stringWithFormat:@"%ld",(long)self.currentPage]};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/point/record"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 NSLog(@"%@",response.responseObject);
                                                 
                                                     //防止crash
                                                 if (![response.responseObject isKindOfClass:[NSDictionary class]]) {
                                                     [_contentTableView.pullToRefreshView stopAnimating];
                                                     
                                                     if (_dataSource.count == 0) {
                                                         
                                                         self.contentTableView.tableHeaderView = self.tableViewHeaderView;
                                                    
                                                     }
                                                     
                                                     return ;
                                                 }
                                                 
                                                     NSMutableArray* list = [[NSMutableArray alloc] initWithCapacity:[self.exchangeModel.countRows integerValue]];
                                                     NSArray* products = [[response responseObject] objectForKey:@"data"];
                                                     
                                                     if (isHeader) {
                                                         
                                                         if ([products isKindOfClass:[NSArray class]] && products.count > 0) {
                                                             
                                                             //下拉刷新
                                                             self.contentTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CGFLOAT_MIN)];
                                                             self.contentTableView.tableFooterView = nil;
                                                             self.contentTableView.showsInfiniteScrolling = YES;
                                                             
                                                             for (NSDictionary* dict in products) {
                                                                 JYMyExchangeModel *model = [[JYMyExchangeModel alloc] initWithDataDic:dict];
                                                                 [list addObject:model];
                                                             }
                                                             
                                                             self.contentTableView.hidden = NO;
                                                             
                                                         }
                                                         else{
                                                             
                                                             self.contentTableView.hidden = YES;
                                                             
                                                             JYCustomView *customView = [[JYCustomView shareInstance]
                                                                                         showEmptyImageWithRect:CGRectMake(0, 134, kScreenWidth, 200)
                                                                                         andImageString:@"blank"
                                                                                         andTitleString:@"这么空...你好意思么"];
                                                             [self.view addSubview:customView];
                                                         }
                                                         
                                                         
                                                         [_dataSource removeAllObjects];
                                                         
                                                         [_dataSource addObjectsFromArray:list];
                                                         [self.contentTableView reloadData];
                                                         
                                                         _exchangeModel.countPage = response.responseObject[@"countPage"];
                                                         _exchangeModel.currentPage = response.responseObject[@"currentPage"];
                                                         
                                                         if (_dataSource.count == 0) {
                                                             
                                                             _contentTableView.tableHeaderView = self.tableViewHeaderView;
                                                         }
                                                         
                                                         [_contentTableView.pullToRefreshView stopAnimating];
                                                         [_contentTableView.infiniteScrollingView stopAnimating];

                                                     }
                                                     else{
                                                         
                                                         if ([products isKindOfClass:[NSArray class]] && products.count > 0) {
                                                             
                                                             for (NSDictionary* dict in products) {
                                                                 JYMyExchangeModel* model = [[JYMyExchangeModel alloc] initWithDataDic:dict];
                                                                 [list addObject:model];
                                                             }
                                                             
                                                             [_dataSource addObjectsFromArray:list];
                                                             [_contentTableView reloadData];
                                                             
                                                             
                                                         } else {
                                                             
                                                             if (_dataSource.count == 0) {
                                                                 _contentTableView.tableHeaderView = self.tableViewHeaderView;
                                                             }
                                                         }
                                                         
                                                         [_contentTableView.infiniteScrollingView stopAnimating];
                                                     }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                                                                  
                                                 if (_dataSource.count == 0) {
                                                     
                                                     self.contentTableView.hidden = YES;

                                                     _contentTableView.tableHeaderView = self.tableViewHeaderView;
                                                     
                                                     [[JYNetworkFailView shareInstance] initWithView:self.view isNav:YES reload:^{
                                                         
                                                         [self getMyExchangeDataForHeaderView:isHeader];
                                                         
                                                     }];
                                                 }
                                                 [_contentTableView.pullToRefreshView stopAnimating];
                                                 
                                                
                                                 
                                             }];
    
}

#pragma mark - UITableViewDataSource And Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.exchangCell = [tableView dequeueReusableCellWithIdentifier:@"JYExchangeDetailTableViewCell"];

    self.exchangCell.isExchangeDetail = YES;
    self.exchangCell.productModel = self.dataSource[indexPath.row];
    self.exchangCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.exchangCell.headerLineView.hidden = YES;
    
    if (indexPath.row == 0) {
        self.exchangCell.headerLineView.hidden = NO;
    }
    
    if ((self.dataSource.count -1) == indexPath.row) {
        
        self.exchangCell.lineView.hidden = NO;
        
    }
    else{
        
        self.exchangCell.lineView.hidden = YES;
    }
    
    return self.exchangCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc
{
    DLog(@"delate");
}

-(void)navBack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JYOrderSuccess object:nil];

    [self popToViewController:[JYQRcodeViewController class]];
}

@end
