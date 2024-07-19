import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    static let channelName = "com.popkov.test.bleTest/advertise"
    
  var advertising: Advertising?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        setupChannel()
        
//        centralManager = CentralManager()
//        centralManager?.start()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupChannel() {
        let vc = window.rootViewController as! FlutterViewController;
        let channel = FlutterMethodChannel(name: Self.channelName,
                                           binaryMessenger: vc.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            if call.method == "startAdvertising" {
                self.startAdvertising()
                result("Advertising started")
            } else if call.method == "stopAdvertising" {
                self.stopAdvertising()
                result("Advertising stopped")
            } else if call.method == "startScan" {
                self.startScan()
                result("Start Scan")
            }  else  {
                result(FlutterMethodNotImplemented);
            }
        }
    }
    
    func startAdvertising() {
        let advertising = Advertising()
        advertising.start()
        self.advertising = advertising
    }
    
    func stopAdvertising() {
        advertising?.stop()
        advertising = nil
    }
    
    func startScan() {
        centralManager.start()
    }
}


//- (BOOL)application:(UIApplication *)application
//    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  [GeneratedPluginRegistrant registerWithRegistry:self];
//  
//  FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
//  FlutterMethodChannel *channel = [FlutterMethodChannel
//                                   methodChannelWithName:@"com.example.ble/advertise"
//                                   binaryMessenger:controller.binaryMessenger];
//  
//  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
//    if ([@"startAdvertising" isEqualToString:call.method]) {
//      [self startAdvertising];
//      result(@"Advertising started");
//    } else {
//      result(FlutterMethodNotImplemented);
//    }
//  }];
//  
//  return [super application:application didFinishLaunchingWithOptions:launchOptions];
//}
