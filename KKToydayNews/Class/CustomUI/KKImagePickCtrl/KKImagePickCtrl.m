//
//  KKImagePickCtrl.m
//  KKToydayNews
//
//  Created by finger on 2017/8/4.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImagePickCtrl.h"
#import "Masonry.h"

@interface KKImagePickCtrl ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIView *buttonView;
@property (nonatomic,strong) UIImageView *imageView ;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *borderView ;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *comfirmBtn;

@end

@implementation KKImagePickCtrl

- (id)initWithImage:(UIImage *)image selViewHeight:(CGFloat)selViewHeight{
    self = [super init];
    if(self){
        _image = image;
        _selViewHeight = selViewHeight;
    }
    return self ;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = YES ;
    [UIApplication sharedApplication].statusBarHidden = YES ;
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO ;
    [UIApplication sharedApplication].statusBarHidden = NO ;
}

#pragma mark -- 初始化UI

- (void)setupUI{
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.buttonView];
    [self.view addSubview:self.borderView];
    [self.scrollView addSubview:self.imageView];
    [self.buttonView addSubview:self.cancelBtn];
    [self.buttonView addSubview:self.comfirmBtn];
    
    self.imageView.image = self.image;
    
    [self adjustView];
    [self resetScrollView];
}

- (void)adjustView{
    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view).multipliedBy(0.5).mas_offset(-self.selViewHeight/2);
    }];
    
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake([[UIScreen mainScreen]bounds].size.width, self.selViewHeight));
    }];
    
    [self.borderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
    }];
    
    CGFloat itemW = [[UIScreen mainScreen]bounds].size.width;
    CGFloat itemH = 0;
    if (self.image.size.width) {
        itemH = self.image.size.height / self.image.size.width * itemW;
    }
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(itemW,MAX(self.selViewHeight,itemH)));
    }];
    
    [self.buttonView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view).multipliedBy(0.5).mas_offset(-self.selViewHeight/2);
    }];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.buttonView.mas_bottom).mas_offset(-50);
        make.left.mas_equalTo(self.buttonView).mas_offset(20);
    }];
    
    [self.comfirmBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.buttonView.mas_bottom).mas_offset(-50);
        make.right.mas_equalTo(self.buttonView).mas_offset(-20);
    }];
}

#pragma mark -- 图片裁剪

- (void)clickButton:(UIButton *)but{
    if(but.tag == 1){
        CGSize size = CGSizeMake(self.scrollView.contentSize.width * [UIScreen mainScreen].scale, self.scrollView.contentSize.height * [UIScreen mainScreen].scale);
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [self.scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect scope = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y,self.scrollView.frame.size.width, self.scrollView.frame.size.height) ;
        self.image = [self clipImage:image scope:scope];
        
        if (self.rstImageHandler) {
            self.rstImageHandler(self.image);
        }
        
    }else{
        if(self.cancelHandler){
            self.cancelHandler();
        }
    }
}

- (UIImage *)clipImage:(UIImage *)image scope:(CGRect)scope{
    
    NSInteger centerX = scope.origin.x;
    NSInteger centerY = scope.origin.y;
    
    CGPoint origin = CGPointMake(-centerX, -centerY);
    
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(scope.size, NO, [UIScreen mainScreen].scale);
    [image drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img ;
}

#pragma mark -- 重置UIScrollView

- (void)resetScrollView{
    
    CGFloat itemW = [[UIScreen mainScreen]bounds].size.width;
    CGFloat itemH = 0;
    
    //根据image的比例来设置高度
    if (self.image.size.width) {
        itemH = self.image.size.height / self.image.size.width * itemW;
    }
    
    self.scrollView.contentSize = CGSizeMake(itemW,MAX(self.selViewHeight,itemH));
    
    NSInteger offsetY = (self.scrollView.contentSize.height - self.selViewHeight ) / 2 ;
    self.scrollView.contentOffset = CGPointMake(0, offsetY) ;
}

#pragma mark -- UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

#pragma mark -- @property getter & setter

- (UIView *)topView{
    if(!_topView){
        _topView = ({
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
            view ;
        });
    }
    return _topView;
}

- (UIView *)buttonView{
    if(!_buttonView){
        _buttonView = ({
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
            view;
        });
    }
    return _buttonView;
}

- (UIView *)borderView{
    if(!_borderView){
        _borderView = [[UIView alloc]init];
        _borderView.backgroundColor = [UIColor clearColor];
        _borderView.userInteractionEnabled = NO ;
        _borderView.layer.borderColor = [UIColor whiteColor].CGColor;
        _borderView.layer.borderWidth = 0.8 ;
    }
    return _borderView;
}

- (UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = ({
            UIScrollView *view = [[UIScrollView alloc]init];
            view.backgroundColor = [UIColor clearColor];
            view.contentSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width, self.image.size.height);
            view.scrollEnabled = YES;
            view.delegate=self;
            view.maximumZoomScale=3.0;
            view.minimumZoomScale=1.0;
            view.clipsToBounds = NO  ;
            view;
        });
    }
    return _scrollView;
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = ({
            UIImageView *view = [[UIImageView alloc]init];
            view.userInteractionEnabled = YES;
            view.layer.masksToBounds = YES ;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view;
        });
    }
    return _imageView;
}

- (UIButton *)cancelBtn{
    if(!_cancelBtn){
        _cancelBtn = ({
            UIButton *cancel = [[UIButton alloc] init];
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancel addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            cancel.tag = 0;
            cancel;
        });
    }
    return _cancelBtn;
}

- (UIButton *)comfirmBtn{
    if(!_comfirmBtn){
        _comfirmBtn = ({
            UIButton *ok = [[UIButton alloc] init];
            [ok setTitle:@"使用" forState:UIControlStateNormal];
            [ok setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [ok addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            ok.tag = 1;
            ok;
        });
    }
    return _comfirmBtn;
}

- (void)setImage:(UIImage *)image{
    
    _image = image;
    
    if(!image){
        return;
    }
    self.imageView.image = image;
    
    [self adjustView];
    [self resetScrollView];
}

- (void)setSelViewHeight:(CGFloat)selViewHeight{
    _selViewHeight = selViewHeight;
    [self adjustView];
    [self resetScrollView];
}

@end
