//
//  KKPersonalCommentCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/1.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalCommentCell.h"
#import "TYAttributedLabel.h"

#define HorizSpace 8
#define VeritSpace 5
#define ImageWH 35
#define SmallImageWH 25
#define TextViewWidth (UIDeviceScreenWidth - 2 * kkPaddingNormal - HorizSpace - ImageWH)
#define replayTextWidth (TextViewWidth - 2 * kkPaddingNormal)
#define LabelHeight 20
#define ButtonHeight 25
#define LineSpace 5 //文字的上下间距

#define commentTextFont [UIFont systemFontOfSize:16]
#define replyFont [UIFont systemFontOfSize:14]

@interface KKPersonalCommentCell ()
@property(nonatomic)UIView *bgView;
@property(nonatomic)UIImageView *headImageView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)UILabel *concernLabel;
@property(nonatomic)TYAttributedLabel *commentTexyView;
@property(nonatomic)UILabel *createTimeLabel;
@property(nonatomic)UILabel *reportLabel;
@property(nonatomic)UILabel *diggNumberLabel;
@property(nonatomic)UIButton *diggBtn;
@property(nonatomic)UIView *splitView;

@property(nonatomic,weak)KKUserCommentDetail *userComment ;
@property(nonatomic,weak)KKCommentDigg *userDigg;

@end

@implementation KKPersonalCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.headImageView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.concernLabel];
    [self.bgView addSubview:self.commentTexyView];
    [self.bgView addSubview:self.createTimeLabel];
    [self.bgView addSubview:self.reportLabel];
    [self.bgView addSubview:self.diggNumberLabel];
    [self.bgView addSubview:self.diggBtn];
    [self.bgView addSubview:self.splitView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.headImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(ImageWH, ImageWH));
    }];
    
    [self.concernLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.bottom.mas_equalTo(self.headImageView.mas_centerY).mas_offset(-2);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.headImageView.mas_centerY).mas_offset(-2);
        make.left.mas_equalTo(self.headImageView.mas_right).mas_offset(HorizSpace);
        make.right.mas_equalTo(self.concernLabel.mas_left).mas_offset(-HorizSpace);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.commentTexyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(VeritSpace);
        make.width.mas_equalTo(TextViewWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.reportLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.top.mas_equalTo(self.commentTexyView.mas_bottom).mas_offset(VeritSpace);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.createTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.commentTexyView);
        make.top.mas_equalTo(self.commentTexyView.mas_bottom).mas_offset(VeritSpace);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    UIImageView *lastView = nil ;
    for(NSInteger i = 0 ; i < 3 ; i ++){
        UIImageView *view = [UIImageView new];
        view.contentMode = UIViewContentModeScaleAspectFill ;
        view.layer.masksToBounds = YES ;
        view.tag = 1000 + i ;
        view.userInteractionEnabled = YES ;
        [self.bgView addSubview:view];
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.createTimeLabel.mas_bottom).mas_offset(VeritSpace);
            if(i == 0){
                make.left.mas_equalTo(self.commentTexyView);
            }else{
                make.left.mas_equalTo(lastView.mas_right).mas_offset(5);
            }
            make.width.mas_equalTo(SmallImageWH);
            make.height.mas_equalTo(SmallImageWH);
        }];
        lastView = view ;
    }
    
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(lastView);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_bottom).mas_offset(-1);
        make.left.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(1.0);
    }];
}

#pragma mark -- 界面刷新

- (void)refreshWithUserComment:(KKUserCommentDetail *)userComment userDigg:(KKCommentDigg *)userDigg{
    self.userComment = userComment ;
    self.userDigg = userDigg;
    if(!userComment.detail.textContainer){
        userComment.detail.textContainer = [KKPersonalCommentCell createCommentData:userComment];
    }
    self.commentTexyView.textContainer = userComment.detail.textContainer;
    [self.commentTexyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(userComment.detail.textContainer.attriTextHeight);
    }];
    
    NSString *headUrl = userComment.detail.user.avatar_url;
    if(!headUrl){
        headUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromCacheForKey:headUrl] ;
    if(image){
        self.headImageView.image = image ;
    }else{
        @weakify(imageCache);
        [imageCache diskImageExistsWithKey:headUrl completion:^(BOOL isInCache) {
            @strongify(imageCache);
            if(isInCache){
                self.headImageView.image = [imageCache imageFromCacheForKey:headUrl] ;
            }else{
                [self.headImageView setCornerImageWithURL:[NSURL URLWithString:headUrl] placeholder:[UIImage imageNamed:@"head_default"]];
            }
        }];
    }
    
    self.nameLabel.text = userComment.detail.user.screen_name;
    
    NSString *diggCount = [[NSNumber numberWithInteger:[userComment.detail.digg_count longLongValue]]convert];
    [self.diggBtn setTitle:[NSString stringWithFormat:@" %@",diggCount] forState:UIControlStateNormal];
    
    NSDictionary *dic = @{NSFontAttributeName:self.diggBtn.titleLabel.font};
    CGSize size = [self.diggBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + 20);
    }];
    
    self.createTimeLabel.text = [NSString stringIntervalSince1970RuleOne:userComment.detail.create_time.longLongValue];
    
    [self checkDiggUser];
}

- (void)checkDiggUser{
    
    for(NSInteger i= 0 ; i < 3 ; i++){
        UIImageView *view = [self.bgView viewWithTag:1000 + i];
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
    
    UIImageView *lastView = nil ;
    
    NSInteger count = [self.userComment.detail.digg_count integerValue];
    for(NSInteger i = 0 ; i < count ; i ++){
        if(i >= 3){
            break ;
        }
        KKUserInfoNew *user = [self.userDigg.data.userList safeObjectAtIndex:i];
        
        NSString *url = user.avatar_url;
        if(!url.length){
            url = @"";
        }
        UIImageView *view = [self.bgView viewWithTag:1000 + i];
        [view removeTapGesture];
        
        @weakify(self);
        [view addTapGestureWithBlock:^(UIView *gestureView) {
            @strongify(self);
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                [self.delegate jumpToUserPage:user.user_id];
            }
        }];
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            if(image){
                view.image = image ;
            }else{
                [view setCornerImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"head_default"]];
            }
        }];
        
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SmallImageWH);
        }];
        lastView = view ;
    }
    
    NSString *totalDigg = @"";
    if(count > 0){
        totalDigg = [[NSNumber numberWithInteger:count]convert];
        totalDigg = [NSString stringWithFormat:@"%@人赞过 >",totalDigg];
        self.diggNumberLabel.text = totalDigg ;
    }else{
        self.diggNumberLabel.text = @"暂无人赞过" ;
    }
    
    if(lastView == nil){
        lastView = [self.bgView viewWithTag:1000];
    }
    [self.diggNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(lastView);
        if(count){
            make.left.mas_equalTo(lastView.mas_right).mas_offset(5);
        }else{
            make.left.mas_equalTo(self.commentTexyView);
        }
        make.height.mas_equalTo(LabelHeight);
        make.right.mas_equalTo(self.diggBtn.mas_left).mas_offset(-5);
    }];
}

- (UILabel *)createShowAllLabel{
    UILabel *view = [UILabel new];
    view.font = replyFont;
    view.textColor = KKColor(25, 93, 157, 1);;
    view.lineBreakMode = NSLineBreakByTruncatingTail;
    view.textAlignment = NSTextAlignmentLeft;
    view.width = replayTextWidth;
    return view ;
}

#pragma mark -- 获取cell的高度

+ (CGFloat)fetchHeightWithUserComment:(KKUserCommentDetail *)item{
    
    CGFloat totalHeight = 0 ;
    
    if(!item.detail.textContainer){
        item.detail.textContainer = [KKPersonalCommentCell createCommentData:item];
    }
    
    totalHeight += item.detail.textContainer.attriTextHeight ;
    
    return totalHeight + 2 * kkPaddingNormal + 3 * VeritSpace + 2 * LabelHeight + SmallImageWH;
}

#pragma mark -- 创建评论文本数据

+ (TYTextContainer *)createCommentData:(KKUserCommentDetail *)item{
    TYTextContainer *data = [TYTextContainer new];
    data.font = commentTextFont;
    data.linesSpacing = LineSpace ;
    data.textColor = [UIColor blackColor];
    data.text = item.detail.text;
    data = [data createTextContainerWithTextWidth:TextViewWidth];
    
    return data;
}

#pragma mark -- @property getter

- (UIView *)bgView{
    if(!_bgView){
        _bgView = ({
            UIView *view = [UIView new];
            view ;
        });
    }
    return _bgView;
}

- (UIImageView *)headImageView{
    if(!_headImageView){
        _headImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                    [self.delegate jumpToUserPage:self.userComment.detail.user.user_id];
                }
            }];
            
            view ;
        });
    }
    return _headImageView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = KKColor(25, 93, 157, 1);
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:14];
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                    [self.delegate jumpToUserPage:self.userComment.detail.user.user_id];
                }
            }];
            
            view;
        });
    }
    return _nameLabel;
}

- (UIButton *)diggBtn{
    if(!_diggBtn){
        _diggBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"comment_like_icon_night_16x16_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"comment_like_icon_press_16x16_"] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTitleColor:KKColor(167, 173, 186, 1.0) forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(diggBtnClick:callback:)]){
                    @weakify(self);
                    [self.delegate diggBtnClick:self.userComment.detail.id_ callback:^(BOOL suc) {
                        @strongify(self);
                        self.diggBtn.selected = suc ;
                    }];
                }
            }];
            
            view ;
        });
    }
    return _diggBtn;
}

- (TYAttributedLabel *)commentTexyView{
    if(!_commentTexyView){
        _commentTexyView = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = KKColor(140, 140, 140, 1.0);
            view.font = commentTextFont;
            view.numberOfLines = 0 ;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.textAlignment = NSTextAlignmentLeft;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _commentTexyView;
}

- (UILabel *)createTimeLabel{
    if(!_createTimeLabel){
        _createTimeLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:12];
            view.textColor = KKColor(40, 40, 40, 1.0);
            view.textAlignment = NSTextAlignmentLeft;
            view;
        });
    }
    return _createTimeLabel;
}

- (UILabel *)concernLabel{
    if(!_concernLabel){
        _concernLabel = ({
            UILabel *view = [UILabel new];
            view.font = commentTextFont;
            view.textColor = [UIColor redColor];
            view.textAlignment = NSTextAlignmentRight;
            view.text = @"关注";
            view.tag = 0 ;
            view.userInteractionEnabled = YES ;
            
            @weakify(view);
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(view);
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(setConcern:userId:callback:)]){
                    BOOL isConcern = !view.tag ;
                    [self.delegate setConcern:isConcern userId:self.userComment.detail.user.user_id callback:^(BOOL isSuc) {
                        if(isSuc){
                            view.text = isConcern ? @"已关注" : @"关注";
                            view.textColor = isConcern ? [UIColor grayColor] : [UIColor grayColor];
                            view.tag = isConcern ;
                        }
                    }];
                }
            }];
            view;
        });
    }
    return _concernLabel;
}

- (UILabel *)reportLabel{
    if(!_reportLabel){
        _reportLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:12];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentRight;
            view.text = @"举报";
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(reportUser:)]){
                    [self.delegate reportUser:self.userComment.detail.user.user_id];
                }
            }];
            
            view;
        });
    }
    return _reportLabel;
}

- (UILabel *)diggNumberLabel{
    if(!_diggNumberLabel){
        _diggNumberLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:12];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(!self.userComment.detail.digg_count){
                    return ;
                }
                if(self.delegate && [self.delegate respondsToSelector:@selector(showAllDiggUser:)]){
                    [self.delegate showAllDiggUser:self.userComment.detail.id_];
                }
            }];
            
            view;
        });
    }
    return _diggNumberLabel;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);;
            view ;
        });
    }
    return _splitView;
}

@end
