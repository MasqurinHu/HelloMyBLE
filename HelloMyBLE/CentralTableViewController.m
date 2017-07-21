//
//  CentralTableViewController.m
//  HelloMyBLE
//
//  Created by Ｍasqurin on 2017/7/21.
//  Copyright © 2017年 Ｍasqurin. All rights reserved.
//

#import "CentralTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DiscoveredItem.h"

@interface CentralTableViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *manager;
    
    NSMutableDictionary *allItems;
    NSDate *lastReloadDataDate;
}
@end

@implementation CentralTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //可能負載重 可以建立背景給他跑
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    allItems = [NSMutableDictionary new];
//    allItems = [NSMutableDictionary dictionary];  Autorelease自動消滅的物件 new的要自己建立自己消滅「在mrc時代」 現在arc用new是比較好的選擇
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)scanEnableValueChanged:(id)sender {
    if ([sender isOn]) {
        [self starToScan];
    }else{
        [self stopScanning];
    }
}
//連上某設備時 掃描停止 以省電 所以拉出來獨立寫 讓程式碼重複利用
-(void)starToScan{
    
//    CBUUID *service1 = [CBUUID UUIDWithString:@"1234"];
//    CBUUID *service2 = [CBUUID UUIDWithString:@"abcd"];
    
    NSArray *services = @[/*service1,service2*/];
    NSDictionary *options =
        @{CBCentralManagerScanOptionAllowDuplicatesKey:@(true)};
    [manager scanForPeripheralsWithServices:services
                                    options:options];
    
}

-(void)stopScanning{
    [manager stopScan];
}

-(void)showAlert:(NSString*) message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - CBCentralDelegate Methods
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBManagerState state = central.state;
    if (state != CBManagerStatePoweredOn) {
        NSString *message = [NSString stringWithFormat:@"BLE is not available(error:%ld),",(long)state];
        [self showAlert:message];
    }
}
//每收到一個廣播就呼叫一次這個方法
-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                 RSSI:(NSNumber *)RSSI{
    DiscoveredItem *existItem = allItems[peripheral.identifier.UUIDString];
    //首次廣播show log
    if (existItem == nil) {
        NSLog(@"Discover:%@,RSSI:%ld,UUID:%@,Data:%@",peripheral.name,RSSI.integerValue,peripheral.identifier,advertisementData.description);
    }
    NSDate *now = [NSDate date];
    
    //Prepare newItems
    DiscoveredItem *newItem = [DiscoveredItem new];
    newItem.peripheral = peripheral;
    newItem.lastRSSI = RSSI.integerValue;
    newItem.lastSeenDate = now;
    //Add to allItems.
    [allItems setObject:newItem
                 forKey:peripheral.identifier.UUIDString];
    // Check if we should make tableView reload data.
    if (existItem == nil ||                                     //發現新設備
        lastReloadDataDate == nil ||                            //重來沒有刷新過 沒必要存在
        [now timeIntervalSinceDate:lastReloadDataDate] > 3.0) { //上次刷新時間超過三秒
        lastReloadDataDate = now;                               //保存時間
        [self.tableView reloadData];                            //刷新畫面
    }
}

@end
