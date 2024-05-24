//
//  MessageCell.m
//  Peripheral
//
//  Created by yfm on 2024/5/24.
//

#import "MessageCell.h"
#import <Masonry/Masonry.h>

@interface MessageCell()

@property (nonatomic) UIView *sendView;
@property (nonatomic) UIView *receivedView;
@property (nonatomic) UILabel *sendLabel;
@property (nonatomic) UILabel *receivedLabel;

@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeUI];
    }
    return self;
}

- (void)config:(Message *)message {
    if (message.type == MessageTypeSend) {
        self.receivedView.hidden = YES;
        self.sendView.hidden = NO;
        self.sendLabel.text = message.text;
    } else {
        self.receivedView.hidden = NO;
        self.sendView.hidden = YES;
        self.receivedLabel.text = message.text;
    }
}

- (void)makeUI {
    [self.contentView addSubview:self.sendView];
    [self.contentView addSubview:self.receivedView];
    [self.sendView addSubview:self.sendLabel];
    [self.receivedView addSubview:self.receivedLabel];
    
    [self.sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(-10);
        make.left.mas_greaterThanOrEqualTo(50);
    }];
    
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sendView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    
    [self.receivedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(10);
        make.right.mas_lessThanOrEqualTo(50);
    }];
    
    [self.receivedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.receivedView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
}

- (UIView *)sendView {
    if(!_sendView) {
        _sendView = [[UIView alloc] init];
        _sendView.layer.cornerRadius = 8;
        _sendView.backgroundColor = UIColor.greenColor;
    }
    return _sendView;
}

- (UIView *)receivedView {
    if(!_receivedView) {
        _receivedView = [[UIView alloc] init];
        _receivedView.layer.cornerRadius = 8;
        _receivedView.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.2];
    }
    return _receivedView;
}

- (UILabel *)sendLabel {
    if(!_sendLabel) {
        _sendLabel = [[UILabel alloc] init];
        _sendLabel.textColor = UIColor.blackColor;
        _sendLabel.textAlignment = NSTextAlignmentRight;
        _sendLabel.font = [UIFont systemFontOfSize:15];
        _sendLabel.numberOfLines = 0;
    }
    return _sendLabel;
}

- (UILabel *)receivedLabel {
    if(!_receivedLabel) {
        _receivedLabel = [[UILabel alloc] init];
        _receivedLabel.textColor = UIColor.blackColor;
        _receivedLabel.textAlignment = NSTextAlignmentLeft;
        _receivedLabel.font = [UIFont systemFontOfSize:15];
        _receivedLabel.numberOfLines = 0;
    }
    return _receivedLabel;
}

@end
