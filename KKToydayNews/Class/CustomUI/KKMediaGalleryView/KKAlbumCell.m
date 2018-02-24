//
//  KKAlbumCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAlbumCell.h"
#import "KKPhotoManager.h"
#import "KKVideoManager.h"

@interface KKAlbumCell()
@property(nonatomic)UIImageView *imageView1;
@property(nonatomic)UIImageView *imageView2;
@property(nonatomic)UIImageView *imageView3;
@property(nonatomic)UILabel *albumNameLabel;
@property(nonatomic)UILabel *imageCountLabel;
@property(nonatomic)UIButton *checkBtn;
@end

@implementation KKAlbumCell

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
    [self.contentView addSubview:self.imageView3];
    [self.contentView addSubview:self.imageView2];
    [self.contentView addSubview:self.imageView1];
    [self.contentView addSubview:self.albumNameLabel];
    [self.contentView addSubview:self.imageCountLabel];
    [self.contentView addSubview:self.checkBtn];
    
    [self.imageView1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.imageView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView1).mas_offset(-3);
        make.centerX.mas_equalTo(self.imageView1);
        make.size.mas_equalTo(CGSizeMake(57, 57));
    }];
    
    [self.imageView3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView2).mas_offset(-3);
        make.centerX.mas_equalTo(self.imageView2);
        make.size.mas_equalTo(CGSizeMake(54, 54));
    }];
    
    [self.albumNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView1.mas_right).mas_offset(12);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).mas_offset(-3);
    }];
    
    [self.imageCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView1.mas_right).mas_offset(12);
        make.top.mas_equalTo(self.contentView.mas_centerY).mas_offset(3);
    }];
    
    [self.checkBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 数据刷新

- (void)refreshWith:(KKMediaAlbumInfo *)albumIfo curtSelAlbumId:(NSString *)albumId cellType:(KKAlbumCellType)type{
    self.albumNameLabel.text = albumIfo.albumName;
    self.imageCountLabel.text = [NSString stringWithFormat:@"%ld",albumIfo.assetCount];
    self.checkBtn.hidden = ![albumIfo.albumId isEqualToString:albumId];
    if(albumIfo.assetCount == 0){
        [self setImage:[UIImage imageWithColor:[UIColor grayColor]] atImageIndex:0];
        [self setImage:nil atImageIndex:1];
        [self setImage:nil atImageIndex:2];
    }else{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for(NSInteger i = 0 ; i < 3 ; i++){
                if (i < albumIfo.assetCount){
                    if(type == KKAlbumCellImage){
                        [[KKPhotoManager sharedInstance]getImageWithAlbumID:albumIfo.albumId index:i needImageSize:CGSizeMake(50, 50) isNeedDegraded:NO sort:NSOrderedDescending block:^(KKPhotoInfo *item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self setImage:item.image atImageIndex:i];
                            });
                        }];
                    }else if(type == KKAlbumCellVideo){
                        [[KKVideoManager sharedInstance]getVideoCorverWithIndex:i needImageSize:CGSizeMake(50, 50) isNeedDegraded:NO block:^(KKVideoInfo *videoInfo) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self setImage:videoInfo.videoCorver atImageIndex:i];
                            });
                        }];
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:nil atImageIndex:i];
                    });
                }
            }
        });
    }
}

- (void)setImage:(UIImage *)image atImageIndex:(NSInteger)index{
    switch (index){
        case 0:{
            self.imageView1.image = image;
            break;
        }
        case 1:{
            self.imageView2.image = image;
            break;
        }
        case 2:{
            self.imageView3.image = image;
            break;
        }
        default:{
            self.imageView1.image = image;
            break;
        }
    }
}

#pragma mark -- @property

- (UIImageView *)imageView1{
    if(!_imageView1){
        _imageView1 = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _imageView1;
}

- (UIImageView *)imageView2{
    if(!_imageView2){
        _imageView2 = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _imageView2;
}

- (UIImageView *)imageView3{
    if(!_imageView3){
        _imageView3 = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _imageView3;
}

- (UILabel *)albumNameLabel{
    if(!_albumNameLabel){
        _albumNameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:15];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view ;
        });
    }
    return _albumNameLabel;
}

- (UILabel *)imageCountLabel{
    if(!_imageCountLabel){
        _imageCountLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:13];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view ;
        });
    }
    return _imageCountLabel;
}

- (UIButton *)checkBtn{
    if(!_checkBtn){
        _checkBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"checkbox-selected"] forState:UIControlStateNormal];
            view ;
        });
    }
    return _checkBtn;
}

@end
