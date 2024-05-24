//
//  MessageCell.h
//  Peripheral
//
//  Created by yfm on 2024/5/24.
//

#import <UIKit/UIKit.h>
#import "MessageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell

- (void)config:(Message *)message;

@end

NS_ASSUME_NONNULL_END
