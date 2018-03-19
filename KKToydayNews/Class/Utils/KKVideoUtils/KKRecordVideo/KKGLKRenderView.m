//
//  KKGLKRenderView.m
//  KKQuickLive
//
//  Created by finger on 2018/3/18.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKGLKRenderView.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>

@interface KKGLKRenderView()
@property(nonatomic,assign)CGRect rectInPixels;
@property(nonatomic,strong)CIContext *context;
@property(nonatomic,strong)GLKView *glkView;
@end

@implementation KKGLKRenderView

- (id)init{
    self = [super init];
    if (self){
        [self setupGlEnv];
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.glkView bindDrawable];
    self.rectInPixels = CGRectMake(0.0, 0.0, self.glkView.drawableWidth, self.glkView.drawableHeight);
}

#pragma mark -- UI

- (void)setupUI{
    [self addSubview:self.glkView];
    [self.glkView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark -- 初始化opengles

- (void)setupGlEnv{
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [self.glkView setContext:eaglContext];
    self.context = [CIContext contextWithEAGLContext:eaglContext
                              options:@{kCIContextWorkingColorSpace:[NSNull null]}];
}

#pragma mark -- 绘制

- (void)drawCIImage:(CIImage *)ciImage{
    [self.context drawImage:ciImage
                 inRect:self.rectInPixels
               fromRect:[ciImage extent]];
    [self.glkView display];
}

#pragma mark -- @property

- (GLKView *)glkView{
    if(!_glkView){
        _glkView = ({
            GLKView *view = [GLKView new];
            view ;
        });
    }
    return _glkView;
}

@end
