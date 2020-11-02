//
//  ViewController.swift
//  scanning BLE
//
//  Created by Darwin Quezada Gaibor on 11/1/20.
//

import UIKit
import KontaktSDK

class ViewController: UIViewController, SensorDelegate {
    var devicesManager: KTKDevicesManager!
    
    // BLE D2D
    private let logger = Log(subsystem: "BLE_UJI", category: "ViewController")
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var sensor: Sensor!
    private let dateFormatter = DateFormatter()
    private let payloadPrefixLength = 6;
    private var didDetect = 0
    private var didRead = 0
    private var didMeasure = 0
    private var didShare = 0
    private var didVisit = 0
    private var payloads: [TargetIdentifier:String] = [:]
    private var didReadPayloads: [String:Date] = [:]
    private var didSharePayloads: [String:Date] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //devicesManager = KTKDevicesManager(delegate: self)
        //devicesManager.startDevicesDiscovery(withInterval: 8.0)
        
        sensor = appDelegate.sensor
        sensor.add(delegate: self)
        
        dateFormatter.dateFormat = "MMdd HH:mm:ss"
        
        if let payloadData = (appDelegate.sensor as? SensorArray)?.payloadData {
            print("PAYLOAD : \(payloadData.shortName)")
        }
    }
    
    // Para herald
    private func timestamp() -> String {
        let timestamp = dateFormatter.string(from: Date())
        return timestamp
    }
    
    private func updateDetection() {
        var payloadShortNames: [String:String] = [:]
        var payloadLastSeenDates: [String:Date] = [:]
        didReadPayloads.forEach() { payloadShortName, date in
            payloadShortNames[payloadShortName] = "read"
            payloadLastSeenDates[payloadShortName] = didReadPayloads[payloadShortName]
        }
        didSharePayloads.forEach() { payloadShortName, date in
            if payloadShortNames[payloadShortName] == nil {
                payloadShortNames[payloadShortName] = "shared"
            } else {
                payloadShortNames[payloadShortName] = "read,shared"
            }
            if let didSharePayloadDate = didSharePayloads[payloadShortName], let didReadPayloadDate = didReadPayloads[payloadShortName], didSharePayloadDate > didReadPayloadDate {
                payloadLastSeenDates[payloadShortName] = didSharePayloadDate
            }
        }
        
        var payloadShortNameList: [String] = []
        payloadShortNames.keys.forEach() { payloadShortName in
            if let method = payloadShortNames[payloadShortName], let lastSeenDate = payloadLastSeenDates[payloadShortName] {
                payloadShortNameList.append("\(payloadShortName) [\(method)] (\(dateFormatter.string(from: lastSeenDate)))")
            }
        }
        payloadShortNameList.sort()
    }

    // MARK:- SensorDelegate

    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
        self.didDetect += 1
        DispatchQueue.main.async {
            NSLog("didDetect: \(self.didDetect) (\(self.timestamp()))")
            //self.manager.delegate = self.bleManagerDel
        }
    }

    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        self.didRead += 1
        payloads[fromTarget] = didRead.shortName
        didReadPayloads[didRead.shortName] = Date()
        DispatchQueue.main.async {
            //NSLog("didRead: \(self.didRead) (\(self.timestamp()))")
            //self.manager.delegate = self.bleManagerDel
            //self.devicesManager = KTKDevicesManager(delegate: self)
        }
    }

    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        self.didShare += 1
        let time = Date()
        didShare.forEach { self.didSharePayloads[$0.shortName] = time }
        DispatchQueue.main.async {
            //NSLog( "didShare: \(self.didShare) (\(self.timestamp()))")
            //self.manager.delegate = self.bleManagerDel
            self.updateDetection()
        }
    }

    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        self.didMeasure += 1;
        if let payloadShortName = payloads[fromTarget] {
            didReadPayloads[payloadShortName] = Date()
        }
        DispatchQueue.main.async {
            //NSLog( "didMeasure: \(self.didMeasure) (\(self.timestamp()))")
            //self.manager.delegate = self.bleManagerDel
            self.updateDetection()
        }
    }

    func sensor(_ sensor: SensorType, didVisit: Location) {
        self.didVisit += 1;
        DispatchQueue.main.async {
            NSLog( "didVisit: \(self.didVisit) (\(self.timestamp()))")
        }
    }
}

/*extension ViewController: KTKDevicesManagerDelegate {
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        if let device = devices.filter({$0.uniqueID == "aBFW"}).first {
            let connection = KTKDeviceConnection(nearbyDevice: device)
            connection.readConfiguration() { configuration, error in
                            if error == nil, let config = configuration {
                                print("Advertising interval for beacon \(String(describing: config.uniqueID)) is \(config.advertisingInterval!)ms")
                            }
                        }
        }
        for device in devices {
            if let uniqueID = device.uniqueID {
                logger.debug("didMeasure (device=\(device.peripheral.identifier),payloadData=\(uniqueID)-\(device.peripheral.name),proximity=RSSI:\(device.rssi))")
                //print("Detected a beacon \(uniqueID) name: \(device.peripheral.name) UUID: \(device.peripheral.identifier)  RSSI: \(device.rssi)")
                
            } else {
                print("Detected a beacon with an unknown unique ID")
            }
        }
    }
    
    func devicesManagerDidFail(toStartDiscovery manager: KTKDevicesManager, withError error: Error) {
        print("Discovery did fail with error: \(String(describing: error))")
    }
    
}*/


