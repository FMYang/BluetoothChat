//
//  FMListCell.m
//  FMBlueCentralDemo
//
//  Created by yfm on 2021/10/29.
//

#import "FMListCell.h"
#import <Masonry/Masonry.h>

@interface FMListCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *connectBtn;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation FMListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)configCell:(CBPeripheral *)peripheral {
    self.peripheral = peripheral;
    self.titleLabel.text = peripheral.name;
    [self update];
}

- (void)connectAction {
    if(self.connectBlock) {
        self.connectBlock(self.indexPath);
    }
}

- (void)update {
    if(self.peripheral.state == CBPeripheralStateConnected) {
        [self.connectBtn setTitle:@"已连接" forState:UIControlStateNormal];
        self.connectBtn.backgroundColor = UIColor.redColor;
    } else {
        [self.connectBtn setTitle:@"连接" forState:UIControlStateNormal];
        self.connectBtn.backgroundColor = UIColor.blueColor;
    }
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.connectBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.connectBtn.mas_left).offset(20);
    }];
    
    [self.connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.width.mas_offset(80);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UIButton *)connectBtn {
    if(!_connectBtn) {
        _connectBtn = [[UIButton alloc] init];
        _connectBtn.backgroundColor = UIColor.blueColor;
        _connectBtn.layer.cornerRadius = 8;
        _connectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_connectBtn setTitle:@"连接" forState:UIControlStateNormal];
        [_connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_connectBtn addTarget:self action:@selector(connectAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;
}

@end
