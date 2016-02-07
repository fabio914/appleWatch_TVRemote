//
//  IRRequest.h
//  watchTV
//
//  Created by Fabio Dela Antonio on 2/7/16.
//  Copyright © 2016 bluenose. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IRRequest;

@protocol IRRequestDelegate <NSObject>

- (void)irRequest:(IRRequest *)request didFinishWithSuccess:(BOOL)success;

@end

@interface IRRequest : NSObject

+ (instancetype)irRequestWithCode:(unsigned long)code delegate:(id<IRRequestDelegate>)delegate;
- (void)cancel;

@end
