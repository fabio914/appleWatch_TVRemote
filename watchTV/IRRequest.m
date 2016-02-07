//
//  IRRequest.m
//  watchTV
//
//  Created by Fabio Dela Antonio on 2/7/16.
//  Copyright © 2016 bluenose. All rights reserved.
//

#import "IRRequest.h"

#define SERVER_IP   @"192.168.4.1"
#define SERVER_PORT 1337

@interface IRRequest () <NSStreamDelegate>

@property (nonatomic, assign) id<IRRequestDelegate> delegate;
@property (nonatomic, assign) unsigned long irCode;
@property (nonatomic, assign) BOOL messageSent;

@end

@implementation IRRequest {
    NSInputStream * _input;
    NSOutputStream * _output;
}

+ (instancetype)irRequestWithCode:(unsigned long)code delegate:(id<IRRequestDelegate>)delegate {
    
    IRRequest * request = [[self alloc] initWithIRCode:code delegate:delegate];
    [request initConnection];
    return [request autorelease];
}

- (instancetype)initWithIRCode:(unsigned long)irCode delegate:(id<IRRequestDelegate>)delegate {
    
    if(self = [super init]) {
        
        _irCode = irCode;
        _delegate = delegate;
    }
    
    return self;
}

- (void)initConnection {
    
    [self cancel];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)SERVER_IP, SERVER_PORT, &readStream, &writeStream);
    
    _input = (NSInputStream *)readStream;
    _output = (NSOutputStream *)writeStream;
    [_input setDelegate:self];
    [_output setDelegate:self];
    [_input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_input open];
    [_output open];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            
            if(theStream == _input) {
                
                uint8_t buffer[1024];
                NSUInteger len;
                
                while ([_input hasBytesAvailable]) {
                    len = [_input read:buffer maxLength:sizeof(buffer)];
                    if(len > 0) {
                        
                        NSString * string = [[[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding] autorelease];
                        
                        if(string) {
                            
                            NSLog(@"Received: %@", string);
                            NSArray * components = [string componentsSeparatedByString:@" "];
                            
                            if([[components[0] uppercaseString] isEqualToString:@"OK"]) {
                                
                                [self cancel];
                                
                                if(self.delegate && [self.delegate respondsToSelector:@selector(irRequest:didFinishWithSuccess:)]) {
                                    
                                    [self.delegate irRequest:self didFinishWithSuccess:YES];
                                }
                            }
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            if(theStream == _output && !_messageSent) {
                
                NSString * message  = [NSString stringWithFormat:@"sendIR(%lu)", _irCode];
                NSData * data = [message dataUsingEncoding:NSASCIIStringEncoding];
                [_output write:[data bytes] maxLength:[data length]];
                NSLog(@"Sent: %@", message);
                _messageSent = YES;
            }
            break;
            
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered:
            
            NSLog(@"Closing");
            [self cancel];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(irRequest:didFinishWithSuccess:)]) {
                
                [self.delegate irRequest:self didFinishWithSuccess:NO];
            }
            break;
        default:
            break;
    }
}

- (void)cancel {
    
    _input.delegate = nil;
    [_input close];
    [_input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _output.delegate = nil;
    [_output close];
    [_output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_input release], _input = nil;
    [_output release], _output = nil;
}

- (void)dealloc {
    
    _delegate = nil;
    [self cancel];
    [super dealloc];
}

@end
