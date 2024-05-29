//
//  ReceivedCell.m
//  Peripheral
//
//  Created by yfm on 2024/5/24.
//

#import "ReceivedCell.h"
#import <Masonry/Masonry.h>

@interface ReceivedCell()

@property (nonatomic) UIView *receivedView;
@property (nonatomic) UILabel *receivedLabel;

@end

@implementation ReceivedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeUI];
    }
    return self;
}

- (void)config:(Message *)message {
    self.receivedLabel.text = message.text;
}

- (void)makeUI {
    [self.contentView addSubview:self.receivedView];
    [self.receivedView addSubview:self.receivedLabel];
        
    [self.receivedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(10);
        make.right.mas_lessThanOrEqualTo(-50);
    }];
    
    [self.receivedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.receivedView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
}

- (UIView *)receivedView {
    if(!_receivedView) {
        _receivedView = [[UIView alloc] init];
        _receivedView.layer.cornerRadius = 8;
        _receivedView.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.2];
    }
    return _receivedView;
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
