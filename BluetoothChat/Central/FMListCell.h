//
//  FMListCell.h
//  FMBlueCentralDemo
//
//  Created by yfm on 2021/10/29.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMListCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^connectBlock)(NSIndexPath *);

- (void)configCell:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
