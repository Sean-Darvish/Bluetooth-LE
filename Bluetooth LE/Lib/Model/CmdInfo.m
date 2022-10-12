//
//  CmdInfo.m
//  Fuelpak FP3
//
//  Created by Mike Saradeth on 10/24/17.
//  Copyright © 2017 Vance & Hines. All rights reserved.
//

#import "CmdInfo.h"
#import "FuelPak_FP4-Swift.h"



@implementation CmdInfo {
    
}



-(instancetype)init
{
    self = [super init];
    [self initVariables];
    return self;
}


- (id)initWithData:(NSString *) cmd
        timeoutInSeconds:(double) timeoutInSeconds
        timeoutRetryMax:(int) timeoutRetryMax
        notificationName:(NSString *) notificationName
        callFrom:(CallFrom) callFrom
{
    if( self = [super init] )
    {
        [self initVariables];
        
        self.cmd = cmd;
        self.timeoutInSeconds = timeoutInSeconds;
        self.timeoutRetryMax = timeoutRetryMax;
        self.notificationName = notificationName;
        self.callFrom = callFrom;
        self.endTime = [self.startTime dateByAddingTimeInterval:timeoutInSeconds];
        self.cmdCode = [self getCmdCode:cmd];
        self.acknowledgementNotificationName = @"";
        self.acknowledgement = @"";
        self.acknowledgementNotificationSent = 0;
        self.dataOnly = false;
        self.isNSData = false;
        self.flashAddress = @"";
    }
    
    return self;
}

- (id)initWithDataOnly:(NSData *) nsData
      timeoutInSeconds:(double) timeoutInSeconds
       timeoutRetryMax:(int) timeoutRetryMax
      notificationName:(NSString *) notificationName
              callFrom:(CallFrom) callFrom
              dataOnly:(Boolean) dataOnly
{
    
    CmdInfo *cmdInfo = [[CmdInfo alloc] initWithData:@"" timeoutInSeconds:timeoutInSeconds timeoutRetryMax:timeoutRetryMax notificationName:notificationName callFrom:callFrom];
    cmdInfo.dataOnly = dataOnly;
    cmdInfo.nsDataOut = nsData;
    
    return cmdInfo;
}

- (void) initVariables
{
    self.cmd = @"";
    self.responseHeader = @"";
    self.respCode = @"";
    self.timeoutInSeconds = 0.0;
    self.notificationName = @"";
    self.startTime = [NSDate date];
    self.endTime = self.startTime;
    self.timedoutAt = self.startTime;;
    self.startTime = self.startTime;;
    self.responseTime = 0.0;
    self.cmdCode = UNKNOWN_CMD;
    self.cmdStatus = CMD_UNDEFINED;
    self.cmdStatusDetail = @"";
    self.callFrom = @"";
    self.packetSize = 0;
    self.responseDataArr = [[NSMutableArray alloc] init];
    self.responseData = @"";
    self.dataOnly = false;
    self.isNSData = false;
    self.flashAddress = @"";
    

    self.key = [self getKey];
}


#pragma mark - Helper Methods

- (void) setByteData:(NSData*)nsData :(int)dataLen
{
    self.nsData = nsData;
    self.dataByte = (unsigned char *)[self.nsData bytes];
    self.dataLen = dataLen;
    
}

                   
- (NSString*) getKey
{
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970] * 1000;  //get current time in milliseconds
    NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
    
    return intervalString;
    
}
#pragma mark - Get/Set Reponse Code

- (void) setReponseCode:(NSString*)responseCode
{
    self.respCode = [self getResponseCode:responseCode];
}



- (ReponseCode) getResponseCode:(NSString*)responseCode
{
    
    if ([responseCode isEqualToString:@"UROTA0"]) {
        return UROTA0;
        
    }else if ([responseCode isEqualToString:@"UROTA1"]) {
        return UROTA1;
        
    }else if ([responseCode isEqualToString:@"UROTA3"]){
        return UROTA3;
    }else if ([responseCode isEqualToString:@"URHM0"]){
        return URHM0;
    }else if ([responseCode isEqualToString:@"SRSM0"]){
        return SRSM0;
    }else {
        
        return UNKNOWN_RESPONSE;
    }
}

#pragma mark - Get command Code


- (CommandCode) getCmdCode:(NSString*)cmd
{
    
    if ([cmd isEqualToString:@"UVIN00"]) {
        return UVIN00;
        
    }else if ([cmd isEqualToString:@"UDEV00"]) {
        return UDEV00;
        
    }else if ([cmd isEqualToString:@"UECM00"]){
        return UECM00;
        
    }else if ([cmd isEqualToString:@"UTT000"]) {
        return UTT000;
        
    }else if ([cmd isEqualToString:@"UTT100"]) {
        return UTT100;
        
    }else if ([cmd isEqualToString:@"UTT200"]) {
        return UTT200;
        
    }else if ([cmd isEqualToString:@"UKT000"]) {
        return UKT000;
        
    }else if ([cmd isEqualToString:@"UKT100"]) {
        return UKT100;
        
    }else if ([cmd isEqualToString:@"UKT200"]) {
        return UKT200;
        
    }else if ([cmd isEqualToString:@"ULV100"]) {
        return ULV100;
        
    }else if ([cmd isEqualToString:@"ULV110"]) {
        return ULV110;
    }else if ([cmd isEqualToString:@"UOTA00"]) {
        return UOTA00;
        
    }else if ([cmd isEqualToString:@"UOTA10"]) {
        return UOTA10;
        
    }else if ([cmd isEqualToString:@"UOTA20"]) {
        return UOTA20;
        
    }else if ([cmd isEqualToString:@"UOTA30"]) {
        return UOTA30;
        
    }else if ([cmd isEqualToString:@"UOTA40"]) {
        return UOTA40;
        
    }else if ([cmd hasPrefix:@"US"]) {
        return US_OTA_VERIFY;
        
    }else {
       
        return UNKNOWN_CMD;
    }
}



@end
