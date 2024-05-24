//
//  ChatVC.m
//  Peripheral
//
//  Created by yfm on 2024/5/23.
//

#import "ChatVC.h"
#import <Masonry/Masonry.h>
#import "MessageManager.h"
#import "MessageCell.h"

UIKIT_STATIC_INLINE UIColor *ZYColorWithHex(NSInteger s) { return [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8)) / 255.0 blue:((s &0xFF))/255.0 alpha:1.0]; }

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface ChatVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic) UIView *bottomView;
@property (nonatomic) UIView *messageView;
@property (nonatomic) UITextField *textfield;
@property (nonatomic) UITableView *tableView;
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"Chat";
    [self makeUI];
    [self addNoti];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom];
    });
}

- (void)addNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)reload {
    [self.tableView reloadData];
    [self scrollToBottom];
}

- (void)scrollToBottom {
    if (MessageManager.shared.messages.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MessageManager.shared.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark -
- (void)keyboardWillShow:(NSNotification *)notification {
    self.messageView.backgroundColor = ZYColorWithHex(0xF7F7F7);
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        self.messageView.frame = CGRectMake(0, kScreenH - rect.size.height - 60, kScreenW, 60);
        
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.messageView.mas_top);
        }];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom];
    });
}

- (void)keyboardWillHide {
    self.messageView.backgroundColor = UIColor.clearColor;
    [UIView animateWithDuration:0.25 animations:^{
        self.messageView.frame = CGRectMake(0, kScreenH - 100, kScreenW, 60);
        
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
    }];
    
    [self scrollToBottom];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MessageManager.shared.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = MessageManager.shared.messages[indexPath.row];
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell config:message];
    return cell;
}

#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length <= 0) return YES;
    NSString *sendMessage = [NSString stringWithFormat:@"!!%@", self.textfield.text];
    Message *message = [[Message alloc] init];
    message.type = MessageTypeSend;
    message.text = self.textfield.text;
    [MessageManager.shared.messages addObject:message];
    [self reload];
    self.textfield.text = @"";
    self.sendData(sendMessage);
    return YES;
}

#pragma mark -

- (void)makeUI {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.messageView];
    [self.messageView addSubview:self.textfield];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    [self.textfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_messageView).offset(10);
        make.bottom.equalTo(_messageView).offset(-10);
        make.left.equalTo(_messageView).offset(10);
        make.right.equalTo(_messageView).offset(-10);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
}

- (UIView *)bottomView {
    if(!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = ZYColorWithHex(0xF7F7F7);
    }
    return _bottomView;
}

- (UIView *)messageView {
    if(!_messageView) {
        _messageView = [[UIView alloc] init];
        _messageView.frame = CGRectMake(0, kScreenH - 100, kScreenW, 60);
    }
    return _messageView;
}

- (UITextField *)textfield {
    if(!_textfield) {
        _textfield = [[UITextField alloc] init];
        _textfield.borderStyle = UITextBorderStyleRoundedRect;
        _textfield.returnKeyType = UIReturnKeySend;
        _textfield.delegate = self;
    }
    return _textfield;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:MessageCell.class forCellReuseIdentifier:@"cell"];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (void)tapAction {
    [self.textfield resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.textfield resignFirstResponder];
}

@end
