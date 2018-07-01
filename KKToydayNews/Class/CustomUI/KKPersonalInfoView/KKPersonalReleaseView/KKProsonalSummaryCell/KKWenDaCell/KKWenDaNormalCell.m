//
//  KKWenDaNormalCell.m
//  KKToydayNews
//
//  Created by finger on 2017/12/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKWenDaNormalCell.h"
#import "TYAttributedLabel.h"

#define space 5.0
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)
#define KKAnswerFont [UIFont systemFontOfSize:14]
#define splitViewHeight 5

@interface KKWenDaNormalCell()
@property(nonatomic,strong)TYAttributedLabel *titleLabel;
@property(nonatomic,strong)TYAttributedLabel *answerLabel;
@property(nonatomic,strong)UILabel *detailLabel;
@property(nonatomic,strong)UIView *splitView;
@property(nonatomic,weak)KKPersonalQAModel *qaModal;
@end

@implementation KKWenDaNormalCell

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
    [self.contentView addSubview:self.answerLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.splitView];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(kkPaddingLarge);
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.right.mas_equalTo(self.contentView).mas_offset(-kkPaddingNormal);
    }];
    
    [self.answerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(space);
        make.left.right.mas_equalTo(self.titleLabel);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.answerLabel.mas_bottom).mas_offset(space);
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
    
    [KKWenDaNormalCell initAttriTextData:modal];
    
    NSString *diggCount = [[NSNumber numberWithInteger:modal.answer.digg_count.longLongValue]convert];
    NSString *browcount = [[NSNumber numberWithInteger:modal.answer.brow_count.longLongValue]convert];
    self.detailLabel.text = [NSString stringWithFormat:@"%@赞 • %@阅读",diggCount,browcount];
    
    self.titleLabel.textContainer = modal.question.textContainer;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(modal.question.textContainer.attriTextHeight);
    }];
    
    self.answerLabel.textContainer = modal.answer.textContainer;
    [self.answerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(modal.answer.textContainer.attriTextHeight);
    }];
}

+ (CGFloat)fetchHeightWithQAModal:(KKPersonalQAModel *)modal{
    [KKWenDaNormalCell initAttriTextData:modal];
    return 2 * kkPaddingLarge + 2 * space + modal.question.textContainer.attriTextHeight + modal.answer.textContainer.attriTextHeight + + KKAnswerFont.lineHeight + splitViewHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKPersonalQAModel *)modal{
    if(modal.question.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor kkColorBlack];
        temp.lineBreakMode = NSLineBreakByWordWrapping;
        temp.text = modal.question.title;
        temp.font = KKTitleFont ;
        modal.question.textContainer = [temp createTextContainerWithTextWidth:KKTitleWidth];
    }
    if(modal.answer.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor grayColor];
        temp.lineBreakMode = NSLineBreakByTruncatingTail;
        temp.text = modal.answer.content_abstract.text;
        temp.font = KKAnswerFont ;
        temp.numberOfLines = 2 ;
        modal.answer.textContainer = [temp createTextContainerWithTextWidth:KKTitleWidth];
    }
}

#pragma mark -- @property

- (TYAttributedLabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
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

- (TYAttributedLabel *)answerLabel{
    if(!_answerLabel){
        _answerLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
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
