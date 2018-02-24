//
//  KKInputView.m
//  KKInputView
//
//  Created by finger on 2017/8/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKInputView.h"
#import "KKTextView.h"
#import "Masonry.h"

#define TextViewHeight 30

@interface KKInputView ()<UITextViewDelegate>
@property(nonatomic)UIButton *bgView;
@property(nonatomic)UIView *inputMaskView;
@property(nonatomic)UIButton *sendBtn;
@property(nonatomic)KKTextView *textView;
@property(nonatomic)CGFloat keyboardHeight;
@property(nonatomic)CGFloat inputMaskViewHeight ;
@property(nonatomic)CGFloat lrPadding;
@property(nonatomic)CGFloat sendButtonWidth;
@end

@implementation KKInputView

- (instancetype)init{
    self = [super init];
    if(self){
        // 添加对键盘的监控
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.bgView];
    [self addSubview:self.inputMaskView];
    [self.inputMaskView addSubview:self.textView];
    [self.inputMaskView addSubview:self.sendBtn];
    
    self.inputMaskViewHeight = 50 ;
    self.lrPadding = 5 ;
    self.sendButtonWidth = 40 ;
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.inputMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([UIScreen mainScreen].bounds.size.height-self.inputMaskViewHeight);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo([[UIScreen mainScreen]bounds].size.width);
        make.height.mas_equalTo(self.inputMaskViewHeight);
    }];
    
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.inputMaskView.mas_centerY);
        make.left.mas_equalTo(self.inputMaskView).mas_offset(self.lrPadding);
        make.width.mas_equalTo(self.inputMaskView).mas_offset(-3 * self.lrPadding - self.sendButtonWidth);
        make.height.mas_equalTo(TextViewHeight);
    }];
    
    [self.sendBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-self.lrPadding);
        make.centerY.mas_equalTo(self.textView);
        make.width.mas_equalTo(self.sendButtonWidth);
        make.height.mas_equalTo(TextViewHeight);
    }];
}

#pragma mark -- 显示和隐藏

- (void)showKeyBoard{
    [self removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.size.mas_equalTo([UIScreen mainScreen].bounds.size);
    }];
    [self layoutIfNeeded];
    [self.textView becomeFirstResponder];
}

- (void)hideKeyBoard{
    [self.textView resignFirstResponder];
}

#pragma mark -- 点击发送按钮

- (void)sendBtnClicked{
    NSString *inputText = self.textView.text;
    if(!inputText.length){
        [self hideKeyBoard];
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(endEditWithInputText:)]){
        [self.delegate endEditWithInputText:inputText];
    }
    
    self.textView.text = @"";
    self.sendBtn.enabled = NO;
    
    [self adjustInputView];
    [self hideKeyBoard];
}

#pragma mark -- UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    self.sendBtn.enabled = textView.text.length;
    [self adjustInputView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        NSString *inputText = self.textView.text;
        if(inputText.length){
            if(self.delegate && [self.delegate respondsToSelector:@selector(endEditWithInputText:)]){
                [self.delegate endEditWithInputText:inputText];
            }
        }
        
        self.textView.text = @"";
        self.sendBtn.enabled = NO;
        
        [self adjustInputView];
        
        return NO;
    }
    return YES;
}

#pragma mark -- 设置输入视图的高度及Y坐标

- (void)adjustInputView{
    
    self.textView.scrollEnabled = NO ;
    
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width,MAXFLOAT)];
    CGFloat height = fmax(TextViewHeight, size.height);
    if(height > 3 * self.textView.font.lineHeight){
        height = 3 * self.textView.font.lineHeight ;
        self.textView.scrollEnabled = YES ;
    }
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    height = height + self.inputMaskViewHeight - TextViewHeight ;
    [self.inputMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.keyboardHeight + [UIScreen mainScreen].bounds.size.height - self.keyboardHeight - height);
        make.height.mas_equalTo(height);
    }];
    
    [self.inputMaskView layoutIfNeeded];
}

#pragma mark -- 键盘的显示和隐藏

- (void)keyBoardWillShow:(NSNotification *) note {
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.inputMaskView.transform = CGAffineTransformMakeTranslation(0, - self.keyboardHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *) note {
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    
    void (^animation)(void) = ^void(void) {
        self.inputMaskView.transform = CGAffineTransformMakeTranslation(0, keyBoardHeight + self.inputMaskView.frame.size.height);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation completion:^(BOOL finished) {
            self.delegate = nil ;
            [self removeFromSuperview];
        }];
    } else {
        animation();
    }
}

#pragma mark --  @property

- (UIButton *)bgView{
    if(!_bgView){
        _bgView = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
            btn ;
        });
    }
    return _bgView;
}

- (UIView *)inputMaskView{
    if(!_inputMaskView){
        _inputMaskView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3].CGColor;
            view.layer.borderWidth = 0.3;
            view ;
        });
    }
    return _inputMaskView;
}

- (KKTextView *)textView{
    if(!_textView){
        _textView = ({
            KKTextView *view = [[KKTextView alloc]init];
            view.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:245.0/255.0 blue:246.0/255.0 alpha:1.0];
            view.returnKeyType = UIReturnKeyNext;
            view.layer.masksToBounds = YES ;
            view.textColor = [UIColor blackColor];
            view.keyboardType = UIKeyboardTypeDefault;
            view.returnKeyType = UIReturnKeySend ;
            view.textAlignment = NSTextAlignmentLeft;
            view.placeholderColor = [UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1.0];
            view.placeholder = @"优质评论将会被优先展示";
            view.delegate = self ;
            view.scrollEnabled = NO ;
            view.textContainerInset = UIEdgeInsetsMake(5,10,0,-10);
            view.layer.cornerRadius = TextViewHeight / 2 ;
            view;
        });
    }
    return _textView;
}

- (UIButton *)sendBtn{
    if(!_sendBtn){
        _sendBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"发布" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:137.0/255.0 blue:218.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
            [btn addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [btn setEnabled:NO];
            btn;
        });
    }
    return _sendBtn;
}

@end
