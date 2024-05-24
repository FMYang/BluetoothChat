//
//  ViewController.m
//  Peripheral
//
//  Created by yfm on 2024/5/23.
//

#import "ViewController.h"
#import "BabyBluetooth.h"
#import <Masonry/Masonry.h>
#import "ChatVC.h"
#import "MessageManager.h"

NSString* const WRITE_CHARACTERISTIC_UUID   = @"EFB99428-39BF-48B4-B4D5-350BB16AE801";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"EFB99428-39BF-48B4-B4D5-350BB16AE802";

typedef NS_ENUM(NSUInteger, ConnectState) {
    ConnectStateReady,
    ConnectStateConnected,
    ConnectStateDisConnected,
};

@interface ViewController () {
    BabyBluetooth *baby;
}

@property (nonatomic) CBCentral *central;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableCharacteristic *characteristic;
@property (nonatomic) ConnectState connectState;
@property (nonatomic) UILabel *stateLabel;
@property (nonatomic) ChatVC *chatVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Peripheral";
    [self makeUI];
    [self makeService];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Chat" style:UIBarButtonItemStylePlain target:self action:@selector(chatAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)chatAction {
    [self gotoChat];
}

- (void)gotoChat {
    self.chatVC = [[ChatVC alloc] init];
    __weak ViewController *weakself = self;
    self.chatVC.sendData = ^(NSString * _Nonnull message) {
        __strong ViewController *strongSelf = weakself;
        if (self.connectState == ConnectStateConnected) {
            NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
            [strongSelf.peripheralManager updateValue:data forCharacteristic:strongSelf.characteristic onSubscribedCentrals:@[strongSelf.central]];
        }
    };
    [self.navigationController pushViewController:self.chatVC animated:YES];
}

- (void)makeUI {
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
}

- (void)makeService {
    //配置第一个服务s1
    CBMutableService *s1 = makeCBService(@"FFF0");
    //配置s1的characteristic
    makeCharacteristicToService(s1, @"FFF1", @"r", @"write");// 读
    makeCharacteristicToService(s1, WRITE_CHARACTERISTIC_UUID, @"rw", @"read"); // 写
    makeCharacteristicToService(s1, NOTIFY_CHARACTERISTIC_UUID, @"n", @"hello5"); // notify
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    //添加服务和启动外设
    baby.bePeripheralWithName(@"FMPeripheral").addServices(@[s1]).startAdvertising();
}

- (void)babyDelegate{
    [baby peripheralModelBlockOnPeripheralManagerDidUpdateState:^(CBPeripheralManager *peripheral) {
        NSLog(@"PeripheralManager trun status code: %ld",(long)peripheral.state);
    }];
    
    [baby peripheralModelBlockOnDidStartAdvertising:^(CBPeripheralManager *peripheral, NSError *error) {
        NSLog(@"didStartAdvertising !!!");
        self.connectState = ConnectStateReady;
    }];
    
    [baby peripheralModelBlockOnDidAddService:^(CBPeripheralManager *peripheral, CBService *service, NSError *error) {
        NSLog(@"Did Add Service uuid: %@ ",service.UUID);
        [peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey: @"FMPeripheral"}];
    }];
    
    [baby peripheralModelBlockOnDidReceiveWriteRequests:^(CBPeripheralManager *peripheral,NSArray *requests) {
        // 收到写请求
        CBATTRequest *request = requests[0];
        NSLog(@"fm didReceiveWriteRequests %@", request);
        NSLog(@"fm data %@", request.value);
        //判断是否有写数据的权限
        if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
            //需要转换成CBMutableCharacteristic对象才能进行写值
            CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
            c.value = request.value;
            // 更新特征值
//            [peripheral updateValue:request.value forCharacteristic:self.characteristic onSubscribedCentrals:@[request.central]];
//            // 告诉中心，更新特征值成功了
//            [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
//            
            NSString *text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
            if ([text hasPrefix:@"!!"]) {
                Message *message = [[Message alloc] init];
                message.text = [text substringFromIndex:2];
                message.type = MessageTypeReceived;
                
                [MessageManager.shared.messages addObject:message];
                [self.chatVC reload];
            }
        }else{
            [peripheral respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
        }
    }];
    
    [baby peripheralModelBlockOnDidSubscribeToCharacteristic:^(CBPeripheralManager *peripheral, CBCentral *central, CBCharacteristic *characteristic) {
        // 连接
        NSLog(@"订阅了 %@的数据",characteristic.UUID);
        if([characteristic.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
            self.characteristic = (CBMutableCharacteristic *)characteristic;
            self.peripheralManager = peripheral;
            self.central = central;
            
            self.connectState = ConnectStateConnected;
            [self gotoChat];
        }
    }];
    
    [baby peripheralModelBlockOnDidUnSubscribeToCharacteristic:^(CBPeripheralManager *peripheral, CBCentral *central, CBCharacteristic *characteristic) {
        // 断开连接
        NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
        
        self.connectState = ConnectStateDisConnected;
    }];
}

#pragma mark -
- (void)setConnectState:(ConnectState)connectState {
    _connectState = connectState;
    self.navigationItem.rightBarButtonItem.enabled = (connectState == ConnectStateConnected);
    switch (connectState) {
        case ConnectStateReady:
            self.stateLabel.text = @"等待连接";
            break;
            
        case ConnectStateConnected:
            self.stateLabel.text = @"已连接";
            break;
            
        case ConnectStateDisConnected:
            self.stateLabel.text = @"连接断开";
            break;
            
        default:
            break;
    }
}

- (UILabel *)stateLabel {
    if(!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = UIColor.redColor;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _stateLabel;
}

@end
