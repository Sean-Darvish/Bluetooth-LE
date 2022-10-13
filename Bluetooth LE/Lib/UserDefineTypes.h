//
//  UserDefineTypes.h
//
//  Created by Shahab Darvish on 11/1/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum
{
    UVIN00 = 0,
    UDEV00,
    UECM00,
    UTT000,
    UTT100,
    UTT200,
    UKT000,
    UKT100,
    UKT200,
    ULV100,
    ULV110,
    UOTA00,
    UOTA10,
    UOTA20,
    UOTA30,
    UOTA40,
    US_OTA_VERIFY,
    SPEEDLIMITER,
    CAMSETTING,
    UNKNOWN_CMD
    
} CommandCode;


typedef enum
{
    CMD_SUCCESS = 0,
    CMD_SUCCESS_NODATA,
    CMD_TIMED_OUT,
    CMD_ERROR,
    CMD_PENDING,
    CMD_UNDEFINED
    
} CommandStatus;

typedef enum
{
    ApiSuccess = 0,
    ApiFailed
} API_RESPONSE_CODE;

typedef enum
{
    SystemInfoViewController = 0,
    DtcViewController,
    LiveDataViewController,
    SystemStatusViewController,
    TestConnection,
    FirmwareUpdateController

} CallFrom;


typedef enum
{
    Classic = 0,
    Ble,
    DeviceDisconnected
    
} ActiveDevice;


typedef enum
{
    BtConnected,
    BtDisconnected,
    BtTestConnection,
    BtConnectionRequest,
    BtConnectionCancelRequest,
    BtScanRequest,
    BtConnectionFailed,
    
} BtStatus;


typedef enum
{
    DevServer,
    StagingServer,
    ProductionServer,
    Dev2Server,
    
} Server;



typedef enum
{
    TurnOffAutotune,
    ApplyLearnedValue,
    FinishAutotune,
    None
} AUTOTUNE_COMMAND;


typedef enum
{
    UPLOAD_ECM_CONTENT,
    UPLOAD_MAP,
    NO_ACTION_CODES,
    SHARE_MAP,
    EDIT_MAP,
    VIEW_EDIT_MAP,
    Call_VAndH,
    Email_VAndH,
    Dealer_Support,
    X_COMMAND_ERROR
    
} ACTION_CODES;



typedef enum
{
    ECM_VERSION_UNKNOWN = 99999,
    
    //J1850
    ECM_VERSION_9 = 9,
    ECM_VERSION_44 = 44,
    ECM_VERSION_159 = 159,
    ECM_VERSION_176 = 176,
    ECM_VERSION_200 = 200,
    ECM_VERSION_202 = 202,
    ECM_VERSION_204 = 204,
    ECM_VERSION_218 = 218,
    ECM_VERSION_171 = 171,
    ECM_VERSION_205 = 205,
    
    //CAN Based
    ECM_VERSION_241 = 241,
    ECM_VERSION_242 = 242,
    ECM_VERSION_357 = 357,
    ECM_VERSION_358 = 358,
    ECM_VERSION_374 = 374,
    ECM_VERSION_375 = 375,
    ECM_VERSION_414 = 414,
    ECM_VERSION_614 = 614,
    ECM_VERSION_617 = 617,
    ECM_VERSION_618 = 618,
    ECM_VERSION_621 = 621,
    ECM_VERSION_721 = 721,
    ECM_VERSION_723 = 723,
    ECM_VERSION_822 = 822,
    ECM_VERSION_823 = 823,
    ECM_VERSION_824 = 824,
    ECM_VERSION_415 = 415,
    ECM_VERSION_921 = 921,  
    ECM_VERSION_941 = 941,
    ECM_VERSION_942 = 942,
    ECM_VERSION_21930 = 21930
    
} ECMVersion;



typedef enum
{
    SOFTAIL = 1,
    DYNA,
    SPORTSTER,
    TOURING,
    CVO_TOURING,
    CVO_SOFTAIL,
    CVO_DYNA,
    STREET,
    S_SERIES,
    UNKNOWN
    
    
} BikeModel2;


typedef enum
{
    DEMO_SOFTAIL = 1,
    DEMO_DYNA,
    DEMO_SPORTSTER_883,
    DEMO_SPORTSTER_1200,
    DEMO_TOURING,
    DEMO_CVO_TOURING,
    DEMO_CVO_SOFTAIL,
    DEMO_CVO_DYNA,
    DEMO_STREET_500,
    DEMO_STREET_750,
    DEMO_TRI_GLIDE,
    DEMO_S_SERIES_SLIM, // JS9
    DEMO_S_SERIES_FATBOY, // JT9
    DEMO_S_SERIES_LOWRIDER,   // Low Rider
    DEMO_SWITCHBACK,   // Switchback
    CUSTOM_VIN
    
} DemoBike;



typedef enum
{
    
    ENGINE_TEMP = 14,
    DESIRED_AFR = 7,
    O2_VOLTAGE_F = 5,
    O2_VOLTAGE_R = 6,
    NUMBER_SAMPLES = 0
    
} AUTOTUNE_LIVEDATA;


@interface UserDefineTypes : NSObject

@end
