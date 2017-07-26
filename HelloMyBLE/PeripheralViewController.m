//
//  SecondViewController.m
//  HelloMyBLE
//
//  Created by Ｍasqurin on 2017/7/21.
//  Copyright © 2017年 Ｍasqurin. All rights reserved.
//

#import "PeripheralViewController.h"
#import "MUIBottonlineTextField.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID            @"8881"
#define CHARACTERISTIC_UUID     @"8882"
#define CHATROOM_NAME           @"5+1的聊天室"

@interface PeripheralViewController ()<CBPeripheralManagerDelegate>
{
    MUIBottonlineTextField *input;
    CBPeripheralManager *manager;
    CBMutableCharacteristic *myCharacteristic;
    
    NSMutableString *messageBuffer;
}
@property (weak, nonatomic) IBOutlet UIView *aaa;
@property (weak, nonatomic) IBOutlet UIButton *bbb;



@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    input = [MUIBottonlineTextField new];
    [_aaa addSubview: input];
    input.translatesAutoresizingMaskIntoConstraints = false;
    NSMutableArray <NSLayoutConstraint*>*lay = [NSMutableArray new];
    [lay addObject:[NSLayoutConstraint constraintWithItem:input attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_aaa attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [lay addObject:[NSLayoutConstraint constraintWithItem:input attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bbb attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [lay addObject:[NSLayoutConstraint constraintWithItem:input attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_aaa attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [lay addObject:[NSLayoutConstraint constraintWithItem:input attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_aaa attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [_aaa addConstraints:lay];
    
    manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)enableSwitchValueChanged:(id)sender {
    if ([sender isOn]) {
        [self startToAdvertise];
    }else{
        [self stopAdvertise];
    }
}

-(void) startToAdvertise{
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
    
    if (myCharacteristic == nil) {
        //生出characteristic
        CBUUID *characteristicUUID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
        //prepare characteristic 屬性資訊 被中心讀取
        CBCharacteristicProperties properties =
        CBCharacteristicPropertyWrite |
        CBCharacteristicPropertyRead |
        CBCharacteristicPropertyNotify;
        //怎樣被存取 可讀可寫
        CBAttributePermissions permissions =
        CBAttributePermissionsReadable |
        CBAttributePermissionsWriteable;
        
        myCharacteristic = [[CBMutableCharacteristic alloc]
                            initWithType:characteristicUUID
                            properties:properties
                            value:nil
                            permissions:permissions];
        //prepare service
        CBMutableService *myService = [[CBMutableService alloc]
                                       initWithType:serviceUUID
                                       primary:true];
        
        myService.characteristics = @[myCharacteristic];
        [manager addService:myService];
        
//        NSInteger i = 5;
//        NSInteger j = i * 2;
//        NSInteger j << 1; 同上 效能更好
        
    }
    
    //Start Advertising!
    NSArray *uuids = @[serviceUUID];//把要廣播的uuid放入array!!! 藍牙機制 可以廣播很多個service characteristic
    NSDictionary *info = @{CBAdvertisementDataLocalNameKey: CHATROOM_NAME,CBAdvertisementDataServiceUUIDsKey: uuids};
    [manager startAdvertising:info];
}

-(void) stopAdvertise{
    [manager stopAdvertising];
}

-(void) sendText:(NSString*) text
         central:(CBCentral*) central {
    
    NSArray *centrals = (central == nil) ? nil : @[central];
    NSData *data= [text dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL result = [manager updateValue:data forCharacteristic:myCharacteristic onSubscribedCentrals:centrals];
    NSLog(@"Send: %@",text);
    NSLog(@"Result: %@",(result?@"OK":@"Fail"));
    
    //keep the text
    if (result == false) {
        messageBuffer = [NSMutableString stringWithString:text];
    }else{
        [messageBuffer appendString:text];
    }
    
}

- (IBAction)sendBtnPressed:(id)sender {
}

#pragma Mark - CBPeripheralManagerDelegate
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    CBManagerState state = peripheral.state;
    
    if (state != CBManagerStatePoweredOn) {
        NSLog(@"BLE is not available. (%ld)",(long)state);
    }
    
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    
    NSString *info = [NSString stringWithFormat:@"* Central subscribed: UUID %@,max: %lu\n",central.identifier.UUIDString,central.maximumUpdateValueLength];
    _logTextView.text = [NSString stringWithFormat:@"%@%@",info,_logTextView.text];
    
    //say hello
    NSString *hello = [NSString stringWithFormat:@"[%@] Welcome!(Total: %ld)\n",CHATROOM_NAME,myCharacteristic.subscribedCentrals.count];
    
    [self sendText:hello central:central];
    NSString *someCComing = [NSString stringWithFormat:@"[%@] SomeComing!(Total: %ld)\n",CHATROOM_NAME,myCharacteristic.subscribedCentrals.count];
    [self sendText:someCComing central:nil];
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    
}

@end
