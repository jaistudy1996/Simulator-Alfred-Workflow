//
//  Dictionary+Extensions.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/18/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Foundation

extension Dictionary {

    func performClosure(matching: (Key, Value) -> Bool, _ closure: (Key, Value) -> Void) {
        for (key, value) in self where matching(key, value) {
            closure(key, value)
        }
    }

}
