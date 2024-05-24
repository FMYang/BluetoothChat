//
//  MessageManager.h
//  Peripheral
//
//  Created by yfm on 2024/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeSend,
    MessageTypeReceived,
};

@interface Message : NSObject

@property (nonatomic) MessageType type;
@property (nonatomic) NSString *text;

@end


@interface MessageManager : NSObject

@property (nonatomic) NSMutableArray<Message *> *messages;

+ (MessageManager *)shared;

@end

NS_ASSUME_NONNULL_END
