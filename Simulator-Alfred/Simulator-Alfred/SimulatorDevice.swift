//
//  SimulatorDevice.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/15/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Cocoa
import Foundation

struct Device: Codable {
    let availability: String
    let state: String
    let isAvailable: Bool
    let name: String
    let udid: String
    let availabilityError: String

    var osInformation: String? // to be set manually
    
    var location: URL {
        return FileManager.devicesFolderPath.appendingPathComponent(udid)
    }
    
    var applications: [Application] {
        return Application.allApplications(at: location)
    }
    
    enum State: String {
        case Shutdown
        case Booted
    }
    
    static func getAlliOSDevices() -> [Device] {
        let pathToXcrun = "/usr/bin/xcrun"
        
        var devices: [Device] = []
        
        struct XcrunResult: Codable {
            let devices: [String: [Device]]
        }
        
        TerminalCommand.run(pathToXcrun, arguments: ["simctl", "list", "-j", "devices", "available"]) { result in
            switch result {
            case .success(let output):
                let jsonDecoder = JSONDecoder()
                let all = try! jsonDecoder.decode(XcrunResult.self, from: output)

                all.devices.performClosure(matching: { key, _ -> Bool in
                    key.contains("iOS")
                }, { key, value in
                    let osInformation = key.components(separatedBy: ".").last ?? "iOS"
                    devices.append(contentsOf: value.map { dev in
                        var dev = dev
                        dev.osInformation = osInformation
                        return dev
                    })
                })

            case .failure(let error):
                print(error)
            }
        }
        
        return devices
    }
    
    static func alfredOutput(devices: [Device]) -> AlfredOutput {
        
        let outputItems = devices.map {
            AlfredOutput.AlfredOutputItem(uid: $0.udid,
                                          title: "\($0.name) \($0.osInformation ?? "iOS")",
                                          subtitle: $0.state,
                                          arg: $0.location.path,
                                          icon: nil,
                                          valid: true)
        }
        
        return AlfredOutput(items: outputItems)
        
    }
}
