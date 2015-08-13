//
//  ViewController.m
//  Ankoromochi
//
//  Created by 浜谷 光吉 on 2015/03/11.
//  Copyright (c) 2015 Mitsuyoshi Hamatani
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ViewController.h"
#import "Konashi.h"

int x[56];
int y[56];
int z[56];

@interface ViewController ()

@end

@implementation ViewController{
    //Konashi connection
    NSString *konashiConnectLabelText;
    IBOutlet UILabel *konashiConnectLabel;
    
    //バッテリーの値
    NSString *batteryLabelText;
    IBOutlet UILabel *batteryLabel;
    IBOutlet UIProgressView *batteryProgView;
    
    //バッテリーの値
    NSString *signalLabelText;
    IBOutlet UILabel *signalLabel;
    IBOutlet UIProgressView *signalProgView;
    

    //加速度センサの値
    //X
    NSString *acclXLabelText;
    IBOutlet UILabel *acclXLabel;
    IBOutlet UIProgressView *acclXProgView;
    //Y
    NSString *acclYLabelText;
    IBOutlet UILabel *acclYLabel;
    IBOutlet UIProgressView *acclYProgView;
    //Z
    NSString *acclZLabelText;
    IBOutlet UILabel *acclZLabel;
    IBOutlet UIProgressView *acclZProgView;

    //サウンド
    SystemSoundID drumSound;
    SystemSoundID cymbalSound;
    SystemSoundID hatSound;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize Konashi
    [Konashi initialize];
    [Konashi addObserver:self
                selector:@selector(ready)
                    name:KONASHI_EVENT_READY];
    [Konashi addObserver:self
                selector:@selector(disconnected)
                    name:KONASHI_EVENT_DISCONNECTED];
    [Konashi addObserver:self
                selector:@selector(i2cRecvADXL345)
                    name:KONASHI_EVENT_I2C_READ_COMPLETE];
    [Konashi addObserver:self
                selector:@selector(updateBattery)
                    name:KONASHI_EVENT_UPDATE_BATTERY_LEVEL];
    [Konashi addObserver:self
                selector:@selector(updateRSSI)
                    name:KONASHI_EVENT_UPDATE_SIGNAL_STRENGTH];
    //サウンド
    //se_maoudamashii_instruments_drum1_bassdrum1
    NSString *path01 = [[NSBundle mainBundle] pathForResource:@"se_maoudamashii_instruments_drum1_bassdrum1" ofType:@"wav"];
    NSURL *url01 = [NSURL fileURLWithPath:path01];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url01), &drumSound);
    //se_maoudamashii_instruments_drum1_cymbal
    NSString *path02 = [[NSBundle mainBundle] pathForResource:@"se_maoudamashii_instruments_drum1_cymbal" ofType:@"wav"];
    NSURL *url02 = [NSURL fileURLWithPath:path02];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url02), &cymbalSound);
    //se_maoudamashii_instruments_drum1_hat
    NSString *path03 = [[NSBundle mainBundle] pathForResource:@"se_maoudamashii_instruments_drum2_hat" ofType:@"wav"];
    NSURL *url03 = [NSURL fileURLWithPath:path03];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url03), &hatSound);
    
    // graphics_viewを作成
    graphics_view = [[GraphicsEx alloc] initWithFrame: CGRectMake(20, 235, 280, 240) ];
    // ビューコントローラにgraphics_viewを貼付ける
    graphics_view.tag = 1;
    [self.view addSubview:graphics_view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findPushed:(id)sender{
    [Konashi find];
}

- (IBAction)disconnectPushed:(id)sender{
    [Konashi reset];
}

- (void)ready {
    NSLog(@"CONNECTED");
    //Konashiの名前を表示
    konashiConnectLabelText = [Konashi peripheralName];
    [konashiConnectLabel setText:konashiConnectLabelText];
    [konashiConnectLabel setTextColor:[UIColor colorWithRed:0.235 green:0.702 blue:0.443 alpha:1.0]];
    
    //For ADXL345
    [Konashi i2cMode:KONASHI_I2C_ENABLE_100K];
    [self i2cSetupADXL345];
    [self i2cRecvADXL345];
    
    //バッテリー
    NSTimer *tm = [NSTimer
                      scheduledTimerWithTimeInterval:60.0f
                      target:self
                      selector:@selector(onBatteryTimer:)
                      userInfo:nil
                      repeats:YES];
    [tm fire];
    
}

- (void)disconnected{
    NSLog(@"DISCONNECTED");
    konashiConnectLabelText = [NSString stringWithFormat:@"Disconnected"];
    [konashiConnectLabel setText:konashiConnectLabelText];
    [konashiConnectLabel setTextColor:[UIColor redColor]];
}


- (void)i2cSetupADXL345{
    unsigned char i2cWord[2];
    i2cWord[0] = 0x31;
    i2cWord[1] = 0x01;
    [Konashi i2cStartCondition];
    [Konashi i2cWrite:2 data:i2cWord address:0x1D];
    [Konashi i2cStopCondition];
    [NSThread sleepForTimeInterval:0.02]; //for stability of I2C connection.
    i2cWord[0] = 0x2D;
    i2cWord[1] = 0x08;
    [Konashi i2cStartCondition];
    [Konashi i2cWrite:2 data:i2cWord address:0x1D];
    [Konashi i2cStopCondition];
    [NSThread sleepForTimeInterval:0.02]; //for stability of I2C connection.
}


- (void)i2cRecvADXL345{
    //NSLog(@"I2CReadADXL345");
    
    // For ADXL345
    unsigned char i2cWord[1];
    unsigned char data[6];
    i2cWord[0] = 0x32;
    [Konashi i2cStartCondition];
    [Konashi i2cWrite:1 data:i2cWord address:0x1D];
    [Konashi i2cRestartCondition];
    [Konashi i2cReadRequest:6 address:0x1D];
    [Konashi i2cRead:6 data:data];
    [Konashi i2cStopCondition];
    //[NSThread sleepForTimeInterval:0.02]; //for stability of I2C connection.
    
    //加速度センサの値を読み取る
    //X
    for (int i=55; i>0; i--) {
        x[i]=x[i-1];
    }
    x[0] = ((int)data[1])-((int)data[0]);
    acclXLabelText = [NSString stringWithFormat:@"%4.2f", (float)x[0]/128];
    [acclXLabel setText:acclXLabelText];
    acclXProgView.progress = (float)(x[0]+256)/512;
    //サウンド
    if ((float)x[0] > 200) {
        AudioServicesPlaySystemSound(cymbalSound);
    }
    //Y
    for (int i=55; i>0; i--) {
        y[i]=y[i-1];
    }
    y[0] = ((int)data[3])-((int)data[2]);
    acclYLabelText = [NSString stringWithFormat:@"%4.2f", (float)y[0]/128];
    [acclYLabel setText:acclYLabelText];
    acclYProgView.progress = (float)(y[0]+256)/512;
    //サウンド
    if ((float)y[0] > 200) {
        AudioServicesPlaySystemSound(hatSound);
    }
    //Z
    for (int i=55; i>0; i--) {
        z[i]=z[i-1];
    }
    z[0] = ((int)data[5])-((int)data[4]);
    acclZLabelText = [NSString stringWithFormat:@"%4.2f", (float)z[0]/128];
    [acclZLabel setText:acclZLabelText];
    acclZProgView.progress = (float)(z[0]+256)/512;
    //サウンド
    if ((float)z[0] > 240) {
        AudioServicesPlaySystemSound(drumSound);
    }
    
    //グラフの更新
    [[self.view viewWithTag:1] setNeedsDisplay];
    
    //BLE電波強度
    [Konashi signalStrengthReadRequest];

}


- (void) updateBattery{
    int batteryVal = [Konashi batteryLevelRead];
    batteryLabelText = [NSString stringWithFormat:@"%d", batteryVal];
    [batteryLabel setText:batteryLabelText];
    batteryProgView.progress = (float)batteryVal/100;
    //NSLog(@"readBattery: %d", batteryVal);
}

- (void) onBatteryTimer:(NSTimer*)timer{
    [Konashi batteryLevelReadRequest];
}

- (void) updateRSSI{
    int signalStrength = [Konashi signalStrengthRead];
    signalLabelText = [NSString stringWithFormat:@"%d", signalStrength];
    [signalLabel setText:signalLabelText];
    signalProgView.progress = (float)(100+signalStrength)/70;
}

/*
- (void) onRSSITimer:(NSTimer*)timer{
    [Konashi signalStrengthReadRequest];
}
*/

@end
