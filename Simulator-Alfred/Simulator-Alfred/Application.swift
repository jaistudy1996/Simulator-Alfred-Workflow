//
//  Application.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/15/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Cocoa
import Foundation

struct Application {
    let name: String
    let icon: NSImage?
    let bundleIdentifier: String?
    let version: String
    let devicePath: URL

    struct Plist: Codable {
        let CFBundleName: String?
        let CFBundleDisplayName: String?
        let CFBundleIcons: [String: BundleIcon]?
        let CFBundleIdentifier: String
        let CFBundleShortVersionString: String
        
        struct BundleIcon: Codable {
            let CFBundleIconFiles: [String]
        }
    }

    init?(_ appPath: URL, devicePath: URL) {
        self.devicePath = devicePath
        
        let applicationPlistPath = appPath.appendingPathComponent("Info.plist")
        let plistDecoder = PropertyListDecoder()
        guard
            FileManager.default.fileExists(atPath: applicationPlistPath.path),
            let data = try? Data(contentsOf: applicationPlistPath),
            let appInfo = try? plistDecoder.decode(Plist.self, from: data)
            else { return nil }
        
        name = appInfo.CFBundleDisplayName ?? appInfo.CFBundleName ?? "No Name found"
        icon = appInfo.CFBundleIcons?.first.flatMap { NSImage(contentsOf: appPath.appendingPathComponent("\($0.value.CFBundleIconFiles.first ?? "")@3x.png")) }
        bundleIdentifier = appInfo.CFBundleIdentifier
        version = appInfo.CFBundleShortVersionString
    }

    var dataPath: URL? {
        let dataDirectoryPath = devicePath.appendingPathComponent("data/Containers/Data/Application")
        guard
            let allApplications = try? FileManager.default.contentsOfDirectory(at: dataDirectoryPath,
                                                                               includingPropertiesForKeys: nil, options: []),
            !allApplications.isEmpty
        else { return nil }

        struct DataPlist: Codable {
            let MCMMetadataIdentifier: String
        }

        return allApplications.first {
            let plistPath = $0.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
            let plistDecoder = PropertyListDecoder()

            guard let dataFromPlist = try? plistDecoder.decode(DataPlist.self, from: Data(contentsOf: plistPath)) else { return false }

            return dataFromPlist.MCMMetadataIdentifier == bundleIdentifier
        }
    }
    
    static func allApplications(at phonePath: URL) -> [Application] {
        let applicationsPath = phonePath.appendingPathComponent("data/Containers/Bundle/Application")
        guard
            let allApplications = try? FileManager.default.contentsOfDirectory(at: applicationsPath,
                                                                               includingPropertiesForKeys: nil, options: []),
            !allApplications.isEmpty
        else { return [] }

        return allApplications.compactMap {
            guard let applicationPath = FileManager.default.getContents(with: "app", at: $0).first else { return nil }
            
            return Application(applicationPath, devicePath: phonePath)
        }
    }

    static func alfredOutput(applications: [Application]) -> AlfredOutput {
        let outputItems = applications.map {
            AlfredOutput.AlfredOutputItem(uid: $0.name,
                                          title: $0.name,
                                          subtitle: $0.bundleIdentifier ?? "",
                                          arg: $0.dataPath?.path ?? "",
                                          icon: nil,
                                          valid: $0.dataPath != nil)
        }

        return AlfredOutput(items: outputItems)
    }
}
