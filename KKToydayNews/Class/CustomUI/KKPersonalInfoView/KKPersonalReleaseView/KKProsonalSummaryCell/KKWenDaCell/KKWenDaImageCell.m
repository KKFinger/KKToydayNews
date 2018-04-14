//
//  KKWenDaImageCell.m
//  KKToydayNews
//
//  Created by finger on 2017/12/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKWenDaImageCell.h"

#define space 5.0
#define KKAnswerTextWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)
#define imageWidth ((KKAnswerTextWidth - 2 * space) / 3.0)
#define imageHeight (imageWidth * 3 / 4)
#define KKQuestionTextWidth (KKAnswerTextWidth - imageWidth - space)
#define splitViewHeight 5
#define KKAnswerFont [UIFont systemFontOfSize:14]

@interface KKWenDaImageCell()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIImageView *answerImageView;
@property(nonatomic,strong)UILabel *answerLabel;
@property(nonatomic,strong)UILabel *detailLabel;
@property(nonatomic,strong)UIView *splitView;
@property(nonatomic,weak)KKPersonalQAModel *qaModal;
@end

@implementation KKWenDaImageCell

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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.answerImageView];
    [self.contentView addSubview:self.answerLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.splitView];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(kkPaddingLarge);
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKQuestionTextWidth);
    }];
    
    [self.answerImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.contentView).mas_offset(-kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageHeight));
    }];
    
    [self.answerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.detailLabel.mas_top).mas_offset(-space);
        make.left.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(KKAnswerTextWidth);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.splitView.mas_top).mas_offset(-kkPaddingLarge);
        make.left.right.mas_equalTo(self.answerLabel);
        make.height.mas_equalTo(KKAnswerFont.lineHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(splitViewHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithQAModal:(KKPersonalQAModel *)modal{
    self.qaModal = modal ;
    
    [KKWenDaImageCell initAttriTextData:modal];
    
    NSString *url = modal.answer.content_abstract.thumb_image_list.firstObject.url ;
    if(!url.length){
        url = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            [self.answerImageView setImage:image];
        }else{
            [self.answerImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]]];
        }
    }];
    
    NSString *diggCount = [[NSNumber numberWithInteger:modal.answer.digg_count.longLongValue]convert];
    NSString *browcount = [[NSNumber numberWithInteger:modal.answer.brow_count.longLongValue]convert];
    self.detailLabel.text = [NSString stringWithFormat:@"%@赞 • %@阅读",diggCount,browcount];
    
    self.titleLabel.attributedText = modal.question.attriTextData.attriText;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(modal.question.attriTextData.attriTextHeight);
    }];
    
    self.answerLabel.attributedText = modal.answer.attriTextData.attriText;
    self.answerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.answerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(modal.answer.attriTextData.attriTextHeight);
    }];
}

+ (CGFloat)fetchHeightWithQAModal:(KKPersonalQAModel *)modal{
    [KKWenDaImageCell initAttriTextData:modal];
    return 2 * kkPaddingLarge + 2 * space + MAX(modal.question.attriTextData.attriTextHeight,imageHeight) + modal.answer.attriTextData.attriTextHeight + + KKAnswerFont.lineHeight + splitViewHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKPersonalQAModel *)modal{
    if(modal.question.attriTextData == nil ){
        modal.question.attriTextData = [KKAttriTextData new];
        modal.question.attriTextData.lineSpace = 3 ;
        modal.question.attriTextData.textColor = [UIColor kkColorBlack];
        modal.question.attriTextData.lineBreak = NSLineBreakByWordWrapping;
        modal.question.attriTextData.originalText = modal.question.title;
        modal.question.attriTextData.maxAttriTextWidth = KKQuestionTextWidth ;
        modal.question.attriTextData.textFont = KKTitleFont ;
    }
    if(modal.answer.attriTextData == nil ){
        modal.answer.attriTextData = [KKAttriTextData new];
        modal.answer.attriTextData.lineSpace = 3 ;
        modal.answer.attriTextData.textColor = [UIColor grayColor];
        modal.answer.attriTextData.lineBreak = NSLineBreakByWordWrapping;
        modal.answer.attriTextData.originalText = modal.answer.content_abstract.text;
        modal.answer.attriTextData.maxAttriTextWidth = KKAnswerTextWidth ;
        modal.answer.attriTextData.textFont = KKAnswerFont ;
        if(modal.answer.attriTextData.attriTextHeight > 2 * KKAnswerFont.lineHeight + 2 * modal.answer.attriTextData.lineSpace){
            modal.answer.attriTextData.attriTextHeight = 2 * KKAnswerFont.lineHeight + 2 * modal.answer.attriTextData.lineSpace;
        }
    }
}

#pragma mark -- @property

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor kkColorBlack];
            view.font = KKTitleFont;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.numberOfLines = 0 ;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _titleLabel;
}

- (UIImageView *)answerImageView{
    if(!_answerImageView){
        _answerImageView = ({
            UIImageView *view = [UIImageView new];
            view.layer.borderWidth = 0.5;
            view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1].CGColor;
            view ;
        });
    }
    return _answerImageView;
}

- (UILabel *)answerLabel{
    if(!_answerLabel){
        _answerLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.font = KKAnswerFont;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.numberOfLines = 0 ;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _answerLabel;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.font = KKAnswerFont;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.numberOfLines = 0 ;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _detailLabel;
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
