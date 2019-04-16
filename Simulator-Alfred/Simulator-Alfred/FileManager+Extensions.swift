//
//  FileManager+Extensions.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/15/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Foundation

extension FileManager {

    static var devicesFolderPath: URL {
        guard
            let libDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        else { fatalError("Unable to locate lib directory") }

        return libDirectory.appendingPathComponent("Developer/CoreSimulator/Devices")
    }

    func getContents(with pathExtension: String, at path: URL) -> [URL] {
        guard
            let allContents = try? contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        else { return [] }

        return allContents.filter { $0.pathExtension == pathExtension }
    }

}
