//
// MQTTSSLSecurityPolicyEncoder.m
// MQTTClient.framework
//
// Copyright (c) 2013-2015, Christoph Krey
//

#import "MQTTSSLSecurityPolicyEncoder.h"

#define LOG_LEVEL_DEF ddLogLevel
#import <CocoaLumberjack/CocoaLumberjack.h>
#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif

@interface MQTTSSLSecurityPolicyEncoder()
@property (nonatomic) BOOL securityPolicyApplied;

@end

@implementation MQTTSSLSecurityPolicyEncoder

- (instancetype)init {
    self = [super init];
    self.securityPolicy = nil;
    self.securityDomain = nil;
    
    return self;
}

- (BOOL)applySSLSecurityPolicy:(NSStream *)writeStream withEvent:(NSStreamEvent)eventCode;
{
    if(!self.securityPolicy){
        return YES;
    }
    
    if(self.securityPolicyApplied){
        return YES;
    }
    
    SecTrustRef serverTrust = (__bridge SecTrustRef) [writeStream propertyForKey: (__bridge NSString *)kCFStreamPropertySSLPeerTrust];
    if(!serverTrust){
        return NO;
    }
    
    self.securityPolicyApplied = [self.securityPolicy evaluateServerTrust:serverTrust forDomain:self.securityDomain];
    return self.securityPolicyApplied;
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    
    if (eventCode &  NSStreamEventHasSpaceAvailable) {
        DDLogVerbose(@"[MQTTCFSocketEncoder] NSStreamEventHasSpaceAvailable");
        if(![self applySSLSecurityPolicy:sender withEvent:eventCode]){
            self.state = MQTTCFSocketEncoderStateError;
            self.error = [NSError errorWithDomain:@"MQTT"
                                             code:errSSLXCertChainInvalid
                                         userInfo:@{NSLocalizedDescriptionKey: @"Unable to apply security policy, the SSL connection is insecure!"}];
        }
    }
    [super stream:sender handleEvent:eventCode];
}

@end