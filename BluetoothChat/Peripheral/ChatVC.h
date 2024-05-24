//
//  ChatVC.h
//  Peripheral
//
//  Created by yfm on 2024/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatVC : UIViewController

@property (nonatomic) void (^sendData)(NSString *message);

- (void)reload;

@end

NS_ASSUME_NONNULL_END
