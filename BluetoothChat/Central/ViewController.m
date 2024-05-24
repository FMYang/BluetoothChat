//
//  ViewController.m
//  Central
//
//  Created by yfm on 2024/5/23.
//

#import "ViewController.h"
#import "ChatVC.h"
#import "MessageManager.h"
#import <Masonry/Masonry.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FMListCell.h"

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

NSString* const WRITE_CHARACTERISTIC_UUID   = @"EFB99428-39BF-48B4-B4D5-350BB16AE801";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"EFB99428-39BF-48B4-B4D5-350BB16AE802";

typedef NS_ENUM(NSUInteger, ConnectState) {
    ConnectStateReady,
    ConnectStateConnected,
    ConnectStateDisConnected,
};

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralList;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBCharacteristic *notiCharacteristic;
@property (nonatomic, strong) CBCharacteristic *resendCharacteristic;
@property (nonatomic, strong) ChatVC *chatVC;

@property (nonatomic) ConnectState connectState;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Central";
    [self makeUI];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Chat" style:UIBarButtonItemStylePlain target:self action:@selector(chatAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)chatAction {
    [self gotoChat];
}

- (void)gotoChat {
    self.chatVC = [[ChatVC alloc] init];
    __weak ViewController *weakSelf = self;
    self.chatVC.sendData = ^(NSString * _Nonnull message) {
        __strong ViewController *strongSelf = weakSelf;
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        [strongSelf.peripheral writeValue:data forCharacteristic:strongSelf.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    };
    [self.navigationController pushViewController:self.chatVC animated:YES];
}

- (BOOL)existPeripheral:(CBPeripheral *)peripheral {
    BOOL exist = NO;
    for(CBPeripheral *p in self.peripheralList) {
        if([p.name isEqualToString:peripheral.name]) {
            exist = YES;
        }
    }
    
    return exist;
}

#pragma mark - 中央管理代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(central.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        
        CBUUID *uuid1 = [CBUUID UUIDWithString:@"FFF0"];
        NSArray<CBPeripheral *> *array = [self.centralManager retrieveConnectedPeripheralsWithServices:@[uuid1]];
        self.peripheralList = [array mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if(peripheral.name.length > 0) {
        if(![self existPeripheral:peripheral]) {
            [self.peripheralList addObject:peripheral];
            [self.tableView reloadData];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 连接成功
    NSLog(@"fm 连接成功");
    self.connectState = ConnectStateConnected;
    [self.centralManager stopScan];
    [peripheral discoverServices:nil];
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self gotoChat];
    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.connectState = ConnectStateReady;
    NSLog(@"fm 连接设备失败");
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.connectState = ConnectStateDisConnected;
    NSLog(@"fm 断开连接");
    [self.tableView reloadData];
}

#pragma mark - CBPeripheralDelegate 配件代理
// 发现服务了
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for(CBService *service in peripheral.services) {
        NSLog(@"发现服务 %@", service);
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

// 发现特征了
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for(CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"发现特征 %@", characteristic);
        // 6、发现特征了
        if([characteristic.UUID.UUIDString isEqualToString:WRITE_CHARACTERISTIC_UUID]) {
            self.writeCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if([characteristic.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
            self.notiCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        // 订阅通知
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [self.peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic characteristic = %@ error = %@", characteristic, error);
}

// 读信号强度
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"RSSI = %@", RSSI);
}

// 更新了配件的特征值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 特征更新了，接受到新数据
    NSData *data = characteristic.value;
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"fm 接受到数据 %@", string);
    
    if ([string hasPrefix:@"!!"]) {
        Message *mesasge = [[Message alloc] init];
        mesasge.text = [string substringFromIndex:2];
        mesasge.type = MessageTypeReceived;
        [MessageManager.shared.messages addObject:mesasge];
        [self.chatVC reload];
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    CBPeripheral *peripheral = self.peripheralList[indexPath.row];
    [cell configCell:peripheral];
    __weak ViewController *weakSelf = self;
    cell.connectBlock = ^(NSIndexPath * _Nonnull aIndexPath) {
        [weakSelf connect:aIndexPath];
    };
    return cell;
}

- (void)connect:(NSIndexPath *)indexPath {
    self.peripheral = self.peripheralList[indexPath.row];
    self.peripheral.delegate = self;

    if(self.peripheral.state == CBPeripheralStateConnected) {
        // 3、断开连接外设
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    } else {
        // 3、连接外设
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
}


#pragma mark -
- (void)makeUI {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark -
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:FMListCell.class forCellReuseIdentifier:@"listCell"];
    }
    return _tableView;
}

- (NSMutableArray<CBPeripheral *> *)peripheralList {
    if(!_peripheralList) {
        _peripheralList = @[].mutableCopy;
    }
    return _peripheralList;
}

- (void)setConnectState:(ConnectState)connectState {
    _connectState = connectState;
    self.navigationItem.rightBarButtonItem.enabled = (connectState == ConnectStateConnected);
}

@end
