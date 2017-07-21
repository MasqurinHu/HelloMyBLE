//
//  DiscoveredItem.h
//  HelloMyBLE
//
//  Created by Ｍasqurin on 2017/7/21.
//  Copyright © 2017年 Ｍasqurin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DiscoveredItem : NSObject
@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,assign) NSInteger lastRSSI;
@property (nonatomic,strong) NSDate *lastSeenDate;

@end
