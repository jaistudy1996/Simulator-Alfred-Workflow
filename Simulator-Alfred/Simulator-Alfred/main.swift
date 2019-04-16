//
//  main.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/15/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Foundation

enum Argument: String {
    case allDevices = "-allDevices"
    case device = "-device"
    case allApplications = "-allApplications"
}

let commandLineArgs = CommandLine.arguments

if let firstArgument = commandLineArgs[safe: 1],
    let argument = Argument(rawValue: firstArgument) {
    switch argument {
    case .allDevices:
        print(Device.alfredOutput(devices: Device.getAlliOSDevices()).jsonString)
    case .device:
        // if we have device then we should have next argument as device URL
        let deviceURLString = commandLineArgs[2]
        if let deviceURL = URL(string: deviceURLString) {
            print(Application.alfredOutput(applications: Application.allApplications(at: deviceURL)).jsonString)
        }
    default:
        break
    }
} else {
    print("Unsupported arguments")
}

