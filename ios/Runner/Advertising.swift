//
//  Advertising.swift
//  Runner
//
//  Created by Алексей Попков on 18.07.2024.
//

import Flutter
import CoreBluetooth

final class Advertising: NSObject {
    let readCharacteristic = Advertising.createReadCharacteristic()
    let writeCharacteristic = Advertising.createWriteCharacteristic()
    lazy var service = createService(characteristics: [readCharacteristic, writeCharacteristic])
    var peripheralManager: CBPeripheralManager?
    
    
    func start() {
        peripheralManager = createPeripheralManager()
    }
    
    func stop() {
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
    }
}

// MARK: - Consts
extension Advertising {
    enum Consts {
        static let name = "BLE Chat"
        static let serviceUUID =             "00001101-0000-1000-8000-00805f9b34fb"
        static let readCharacteristicUUID =  "00003301-0000-1000-8000-00805f9b34fb"
        static let writeCharacteristicUUID = "00002201-0000-1000-8000-00805f9b34fb"
    }
}

// MARK: - CBPeripheralManagerDelegate
extension Advertising: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        
        switch peripheral.state {
        case .unknown, .resetting, .unsupported, .unauthorized, .poweredOff:
            break
        case .poweredOn:
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
            }
            
            peripheralManager?.add(service)
            
            
            peripheral.startAdvertising([CBAdvertisementDataLocalNameKey: Consts.name,
                                      CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
            
//            peripheral.startAdvertising([CBAdvertisementDataLocalNameKey: Consts.name])
        @unknown default:
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
//        print(requests)
        
        for request in requests {
            if request.characteristic.uuid == writeCharacteristic.uuid {
                if let value = request.value {
                    let receivedString = String(data: value, encoding: .utf8)
                    print("Received write request: \(receivedString ?? "nil")")
                    
                    // Respond to the write request
                    peripheral.respond(to: request, withResult: .success)
                    
                    peripheral.updateValue(value, for: writeCharacteristic, onSubscribedCentrals: [request.central])
//                    peripheral.updateValue(value, for: readCharacteristic, onSubscribedCentrals: [request.central])
                } else {
                    peripheral.respond(to: request, withResult: .invalidAttributeValueLength)
                }
            } else {
                peripheral.respond(to: request, withResult: .requestNotSupported)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print(request)
    }
}

// MARK: - create Advertising data
extension Advertising {
  static func createReadCharacteristic() -> CBMutableCharacteristic {
        let uuid = CBUUID(string: Consts.readCharacteristicUUID)
        
        return CBMutableCharacteristic(type: uuid,
                                       properties: [.read],
                                       value: nil,//Data("123".utf8),
                                       permissions: [.readable])
    }
    
    static func createWriteCharacteristic() -> CBMutableCharacteristic {
        let uuid = CBUUID(string: Consts.writeCharacteristicUUID)
        
        return CBMutableCharacteristic(type: uuid,
                                       properties: [.write, .read, .notify],
                                       value: nil,
                                       permissions: [.writeable, .readable])
    }
    
    func createPeripheralManager() -> CBPeripheralManager{
        let result = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//        result.add(service)
        return result
    }
    
    func createService(characteristics: [CBMutableCharacteristic]) -> CBMutableService {
        let uuid = CBUUID(string: Consts.serviceUUID)
        
        let result = CBMutableService(type: uuid, primary: true)
        
        
       
        result.characteristics = characteristics
        
        return result
    }
}
