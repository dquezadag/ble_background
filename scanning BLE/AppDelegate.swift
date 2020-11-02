//
//  AppDelegate.swift
//  scanning BLE
//
//  Created by Darwin Quezada Gaibor on 11/1/20.
//

import UIKit
import KontaktSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, SensorDelegate {
    private let logger = Log(subsystem: "BLE_UJI", category: "AppDelegate")

    // Payload data supplier, sensor and contact log
    var payloadDataSupplier: PayloadDataSupplier?
    var sensor: Sensor?

    /// Generate unique and consistent device identifier for testing detection and tracking
    private func identifier() -> Int32 {
        let text = UIDevice.current.name + ":" + UIDevice.current.model + ":" + UIDevice.current.systemName + ":" + UIDevice.current.systemVersion
        var hash = UInt64 (5381)
        let buf = [UInt8](text.utf8)
        for b in buf {
            hash = 127 * (hash & 0x00ffffffffffffff) + UInt64(b)
        }
        let value = Int32(hash.remainderReportingOverflow(dividingBy: UInt64(Int32.max)).partialValue)
        //logger.debug("Identifier My device (text=\(text),hash=\(hash),value=\(value))")
        return value
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Configure Kontakt API
        Kontakt.setAPIKey("jJNmAOVROhCBruHnLDQGnJhXWmHjKpOE")

        // Register User Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // Parse errors and track state
        }
        
        //logger.debug("application:didFinishLaunchingWithOptions")
        
        payloadDataSupplier = MockSonarPayloadSupplier(identifier: identifier())
        sensor = SensorArray(payloadDataSupplier!)
        sensor?.add(delegate: self)
        sensor?.start()
        
        // Check if app was launched by location event triggered by iBeacon
        /*if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            // Start scanning beacons if true
            BeaconScanningManager.sharedInstance.resumeScanning()
        }*/
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
        //logger.info(sensor.rawValue + ",didDetect=" + didDetect.description)
    }
    
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        //logger.info(sensor.rawValue + ",didRead=" + didRead.shortName + ",fromTarget=" + fromTarget.description)
    }
    
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        //let payloads = didShare.map { $0.shortName }
        //logger.info(sensor.rawValue + ",didShare=" + payloads.description + ",fromTarget=" + fromTarget.description)
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        //logger.info(sensor.rawValue + ",didMeasure=" + didMeasure.description + ",fromTarget=" + fromTarget.description)
    }
    
    func sensor(_ sensor: SensorType, didVisit: Location) {
        //logger.info(sensor.rawValue + ",didVisit=" + didVisit.description)
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier, withPayload: PayloadData) {
        //logger.info(sensor.rawValue + ",didMeasure=" + didMeasure.description + ",fromTarget=" + fromTarget.description + ",withPayload=" + withPayload.shortName)
    }
    
    func sensor(_ sensor: SensorType, didUpdateState: SensorState) {
        //logger.info(sensor.rawValue + ",didUpdateState=" + didUpdateState.rawValue)
    }


}

