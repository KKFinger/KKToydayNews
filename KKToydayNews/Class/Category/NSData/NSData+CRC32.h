//
//  NSData+CRC32.h
//  CRC32_iOS
//
//  Created by 宣佚 on 15/7/14.
//  Copyright (c) 2015年 宣佚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface NSData (CRC32)

-(int32_t) crc_32;

-(uLong)getCRC32;

@end
