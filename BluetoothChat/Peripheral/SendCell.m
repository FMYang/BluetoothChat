//
//  SendCell.m
//  Peripheral
//
//  Created by yfm on 2024/5/29.
//

#import "SendCell.h"
#import <Masonry/Masonry.h>

@interface SendCell()

@property (nonatomic) UIView *sendView;
@property (nonatomic) UILabel *sendLabel;

@end

@implementation SendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeUI];
    }
    return self;
}

- (void)config:(Message *)message {
    self.sendLabel.text = message.text;
}

- (void)makeUI {
    [self.contentView addSubview:self.sendView];
    [self.sendView addSubview:self.sendLabel];
    
    [self.sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(-10);
        make.left.mas_greaterThanOrEqualTo(50);
    }];
    
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sendView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
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

- (UILabel *)sendLabel {
    if(!_sendLabel) {
        _sendLabel = [[UILabel alloc] init];
        _sendLabel.textColor = UIColor.blackColor;
        _sendLabel.font = [UIFont systemFontOfSize:15];
        _sendLabel.numberOfLines = 0;
    }
    return _sendLabel;
}

@end
