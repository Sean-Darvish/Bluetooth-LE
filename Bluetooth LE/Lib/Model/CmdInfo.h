//
//  CmdInfo.h
//  Fuelpak FP3
//
//  Created by Mike Saradeth on 10/24/17.
//  Copyright © 2017 Vance & Hines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UserDefineTypes.h"

typedef enum
{
    UROTA0 = 0,
    UROTA1,
    UROTA3,
    UNKNOWN_RESPONSE,
    URHM0,
    SRSM0
} ReponseCode;


@class Sector;
@interface CmdInfo : NSObject

@property (strong, nonatomic) NSString *key;
//Data to be used in BTUTIL
@property (strong, nonatomic) NSData *nsDataOut;    //Data to Send out
@property (strong, nonatomic) NSString *acknowledgement;
@property (strong, nonatomic) NSString *responseCode;
@property (assign) ReponseCode respCode;

//Keeping track of command timeout and etc.
@property (strong, nonatomic) NSString *cmd;
@property (strong, nonatomic) NSString *responseHeader;
@property  double timeoutInSeconds;
@property  int timeoutRetryMax;
@property (strong, nonatomic) NSString *notificationName;
@property (strong, nonatomic) NSString *acknowledgementNotificationName;
@property (assign) int acknowledgementNotificationSent;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSDate *timedoutAt;
@property  double responseTime;
@property  CommandCode cmdCode;
@property CommandStatus cmdStatus;
@property (strong, nonatomic) NSString *cmdStatusDetail;
@property CallFrom callFrom;
@property int packetSize;
@property int sector;
@property int sectorOffset;
@property int size;
@property int speedLimiter;
@property int tableid;
@property int tableindex;
@property float camIntakeValFront;
@property float camIntakeValRear;
@property int camIntakeValFrontSectorOffset;
@property int camIntakeValRearSectorOffset;

@property (assign) Boolean dataOnly;
@property (assign) Boolean isNSData;
@property (strong, nonatomic) NSString *flashAddress;

//Reponse data
@property (strong, nonatomic) NSMutableArray *responseDataArr;
@property (strong, nonatomic) NSString *responseData;

//Data to be used in EAController
@property (strong, nonatomic) NSString *dataHex;
@property (strong, nonatomic) NSString *dataAscii;
@property (strong, nonatomic) NSData *nsData;
@property unsigned char *dataByte;
@property Sector *responseSector;


@property int dataLen;



- (id)initWithData:(NSString *) cmd
  timeoutInSeconds:(double) timeoutInSeconds
   timeoutRetryMax:(int) timeoutRetryMax
  notificationName:(NSString *) notificationName
          callFrom:(CallFrom) callFrom;

- (id)initWithDataOnly:(NSData *) nsData
      timeoutInSeconds:(double) timeoutInSeconds
       timeoutRetryMax:(int) timeoutRetryMax
      notificationName:(NSString *) notificationName
              callFrom:(CallFrom) callFrom
              dataOnly:(Boolean) dataOnly;

- (void) setByteData:(NSData*)nsData :(int)dataLen;
- (void) setReponseCode:(NSString*)respCode;
- (ReponseCode) getResponseCode:(NSString*)respCode;

@end
