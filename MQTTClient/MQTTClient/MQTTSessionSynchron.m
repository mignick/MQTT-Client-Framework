//
// MQTTSessionSynchron.m
// MQTTClient.framework
//
// Copyright (c) 2013-2015, Christoph Krey
//

/**
 Synchronous API
 
 @author Christoph Krey krey.christoph@gmail.com
 @see http://mqtt.org
 */

#import "MQTTSession.h"
#import "MQTTSessionLegacy.h"
#import "MQTTSessionSynchron.h"

#define LOG_LEVEL_DEF ddLogLevel
#import <CocoaLumberjack/CocoaLumberjack.h>
#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif

@interface MQTTSession()
@property (nonatomic) BOOL synchronPub;
@property (nonatomic) UInt16 synchronPubMid;
@property (nonatomic) BOOL synchronUnsub;
@property (nonatomic) UInt16 synchronUnsubMid;
@property (nonatomic) BOOL synchronSub;
@property (nonatomic) UInt16 synchronSubMid;
@property (nonatomic) BOOL synchronConnect;
@property (nonatomic) BOOL synchronDisconnect;

@end

@implementation MQTTSession(Synchron)


- (BOOL)connectAndWaitToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL {
    return [self connectAndWaitToHost:host port:port usingSSL:usingSSL timeout:0];
}

- (BOOL)connectAndWaitToHost:(NSString*)host port:(UInt32)port usingSSL:(BOOL)usingSSL timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronConnect = TRUE;
    
    [self connectToHost:host port:port usingSSL:usingSSL];
    
    while (self.synchronConnect && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MQTTSessionSynchron] waiting for connect");
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    DDLogVerbose(@"[MQTTSessionSynchron] end connect");
    
    return (self.status == MQTTSessionStatusConnected);
}

- (BOOL)subscribeAndWaitToTopic:(NSString *)topic atLevel:(MQTTQosLevel)qosLevel {
    return [self subscribeAndWaitToTopic:topic atLevel:qosLevel timeout:0];
}

- (BOOL)subscribeAndWaitToTopic:(NSString *)topic atLevel:(MQTTQosLevel)qosLevel timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronSub = TRUE;
    UInt16 mid = [self subscribeToTopic:topic atLevel:qosLevel];
    self.synchronSubMid = mid;
    
    while (self.synchronSub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MQTTSessionSynchron] waiting for suback %d", mid);
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    DDLogVerbose(@"[MQTTSessionSynchron] end subscribe");
    
    if (self.synchronSubMid == mid) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL)subscribeAndWaitToTopics:(NSDictionary<NSString *, NSNumber *> *)topics {
    return [self subscribeAndWaitToTopics:topics timeout:0];
}

- (BOOL)subscribeAndWaitToTopics:(NSDictionary<NSString *, NSNumber *> *)topics timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronSub = TRUE;
    UInt16 mid = [self subscribeToTopics:topics];
    self.synchronSubMid = mid;
    
    while (self.synchronSub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MQTTSessionSynchron] waiting for suback %d", mid);
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    DDLogVerbose(@"[MQTTSessionSynchron] end subscribe");
    
    if (self.synchronSubMid == mid) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL)unsubscribeAndWaitTopic:(NSString *)theTopic {
    return [self unsubscribeAndWaitTopic:theTopic timeout:0];
}

- (BOOL)unsubscribeAndWaitTopic:(NSString *)theTopic timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    self.synchronUnsub = TRUE;
    UInt16 mid = [self unsubscribeTopic:theTopic];
    self.synchronUnsubMid = mid;
    
    while (self.synchronUnsub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MQTTSessionSynchron] waiting for unsuback %d", mid);
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    DDLogVerbose(@"[MQTTSessionSynchron] end unsubscribe");
    
    if (self.synchronUnsubMid == mid) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL)unsubscribeAndWaitTopics:(NSArray<NSString *> *)topics {
    return [self unsubscribeAndWaitTopics:topics timeout:0];
}

- (BOOL)unsubscribeAndWaitTopics:(NSArray<NSString *> *)topics timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronUnsub = TRUE;
    UInt16 mid = [self unsubscribeTopics:topics];
    self.synchronUnsubMid = mid;
    
    while (self.synchronUnsub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MQTTSessionSynchron] waiting for unsuback %d", mid);
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    
    DDLogVerbose(@"[MQTTSessionSynchron] end unsubscribe");
    
    if (self.synchronUnsubMid == mid) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL)publishAndWaitData:(NSData*)data
                   onTopic:(NSString*)topic
                    retain:(BOOL)retainFlag
                       qos:(MQTTQosLevel)qos {
    return [self publishAndWaitData:data onTopic:topic retain:retainFlag qos:qos timeout:0];
}

- (BOOL)publishAndWaitData:(NSData*)data
                   onTopic:(NSString*)topic
                    retain:(BOOL)retainFlag
                       qos:(MQTTQosLevel)qos
                   timeout:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];

    if (qos != MQTTQosLevelAtMostOnce) {
        self.synchronPub = TRUE;
    }
    
    UInt16 mid = [self publishData:data onTopic:topic retain:retainFlag qos:qos];
    if (qos == MQTTQosLevelAtMostOnce) {
        return TRUE;
    } else {
        self.synchronPubMid = mid;
        
        while (self.synchronPub && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
            DDLogVerbose(@"[MQTTSessionSynchron] waiting for mid %d", mid);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        DDLogVerbose(@"[MQTTSessionSynchron] end publish");
        
        if (self.synchronPubMid == mid) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
}

- (void)closeAndWait {
    [self closeAndWait:0];
}

- (void)closeAndWait:(NSTimeInterval)timeout {
    NSDate *started = [NSDate date];
    self.synchronDisconnect = TRUE;
    [self close];
    
    while (self.synchronDisconnect && (timeout == 0 || [started timeIntervalSince1970] + timeout > [[NSDate date] timeIntervalSince1970])) {
        DDLogVerbose(@"[MQTTSessionSynchron] waiting for close");
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    DDLogVerbose(@"[MQTTSessionSynchron] end close");
    
}

@end
