//
//  MessageManager.m
//  Peripheral
//
//  Created by yfm on 2024/5/24.
//

#import "MessageManager.h"

@implementation Message
@end

@implementation MessageManager

+ (MessageManager *)shared {
    static MessageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSMutableArray<Message *> *)messages {
    if (!_messages) {
        _messages = @[].mutableCopy;
    }
    return _messages;
}

@end
