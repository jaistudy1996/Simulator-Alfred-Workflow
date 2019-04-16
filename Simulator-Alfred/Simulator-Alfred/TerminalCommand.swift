//
//  TerminalCommand.swift
//  Simulator-Alfred
//
//  Created by Jayant Arora on 4/15/19.
//  Copyright © 2019 Jayant Arora. All rights reserved.
//

import Foundation

enum TerminalCommandError: Error {
    case invalidCommand
    case failedToRun
    case error(String)
}

class TerminalCommand {

    typealias CommandCompletion = (Result<Data, TerminalCommandError>) -> Void

    static func run(_ pathTocommand: String, arguments: [String] = [], completion: CommandCompletion) {
        guard
            !pathTocommand.isEmpty
        else {
            completion(.failure(.invalidCommand))
            return
        }

        let outputPipe = Pipe()
        let outputErrorPipe = Pipe()

        let task = Process()
        task.executableURL = URL(fileURLWithPath: pathTocommand)
        task.arguments = arguments.isEmpty ? nil : arguments
        task.standardOutput = outputPipe
        task.standardError = outputErrorPipe

        guard
            (try? task.run()) != nil
        else {
            completion(.failure(.failedToRun))
            return
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputErrorData = outputErrorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(decoding: outputErrorData, as: UTF8.self)

        guard
            error.isEmpty
        else {
            completion(.failure(.error(error)))
            return
        }

        return completion(.success(outputData))
    }

}

