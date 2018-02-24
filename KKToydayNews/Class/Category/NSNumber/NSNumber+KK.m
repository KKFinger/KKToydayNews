//
//  NSNumber+KK.m
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "NSNumber+KK.h"

@implementation NSNumber(KK)

- (NSString *)convert {
    NSNumber *compareNumber0 = @(1);
    NSNumber *compareNumber1 = @(10000);
    NSNumber *compareNumber2 = @(100000);
    NSNumber *compareNumber3 = @(1000000);
    NSDecimalNumber *compareDNumber0 = [NSDecimalNumber decimalNumberWithString:compareNumber0.description];
    NSDecimalNumber *compareDNumber1 = [NSDecimalNumber decimalNumberWithString:compareNumber1.description];
    
    
    NSDecimalNumberHandler *roundingBehavior1 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                                       scale:2
                                                                                            raiseOnExactness:NO
                                                                                             raiseOnOverflow:NO
                                                                                            raiseOnUnderflow:NO
                                                                                         raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *roundingBehavior2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                                       scale:1
                                                                                            raiseOnExactness:NO
                                                                                             raiseOnOverflow:NO
                                                                                            raiseOnUnderflow:NO
                                                                                         raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *roundingBehavior3 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                                       scale:0
                                                                                            raiseOnExactness:NO
                                                                                             raiseOnOverflow:NO
                                                                                            raiseOnUnderflow:NO
                                                                                         raiseOnDivideByZero:NO];
    
    NSDecimalNumber *originNumber = [NSDecimalNumber decimalNumberWithString:self.description];
    NSComparisonResult result1 = [originNumber compare:compareNumber1];
    
    NSDecimalNumber *decimalNumber = nil;
    if (result1 == NSOrderedAscending || result1 == NSOrderedSame) {
        decimalNumber = [originNumber decimalNumberByDividingBy:compareDNumber0 withBehavior:roundingBehavior1];
        return decimalNumber.stringValue;
    } else {
        NSComparisonResult result2 = [originNumber compare:compareNumber2];
        if (result2 == NSOrderedAscending || result2 == NSOrderedSame) {
            decimalNumber = [originNumber decimalNumberByDividingBy:compareDNumber1 withBehavior:roundingBehavior1];
        } else {
            NSComparisonResult result3 = [originNumber compare:compareNumber3];
            if (result3 == NSOrderedAscending || result3 == NSOrderedSame) {
                decimalNumber = [originNumber decimalNumberByDividingBy:compareDNumber1 withBehavior:roundingBehavior2];
            } else {
                decimalNumber = [originNumber decimalNumberByDividingBy:compareDNumber1 withBehavior:roundingBehavior3];
            }
        }
        return [NSString stringWithFormat:@"%@万", decimalNumber.stringValue];
    }
}

@end
