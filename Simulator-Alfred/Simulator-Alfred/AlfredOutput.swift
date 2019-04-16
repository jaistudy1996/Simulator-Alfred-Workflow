//
//  AlfredOutput.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/15/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Foundation

struct AlfredOutput: Codable {
    let items: [AlfredOutputItem]
    
    struct AlfredOutputItem: Codable {
        let uid: String
        let title: String
        let subtitle: String
        let arg: String // argument passed out
        let icon: Icon?
        let valid: Bool? // alfred defaults this to true
    }
    
    struct Icon: Codable {
        let type: String
        let path: String
    }
    
    var jsonString: String {
        let jsonEncoder = JSONEncoder()
        guard let encodedJSON = try? jsonEncoder.encode(self) else { return "" }
        
        return String(data: encodedJSON, encoding: .utf8) ?? ""
    }
}
