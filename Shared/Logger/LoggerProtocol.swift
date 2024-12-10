//
//  LoggerProtocol.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 3.12.24.
//

import Foundation

protocol LoggerProtocol {
    func logDebug(_ message: String)
    func logInfo(_ message: String)
    func logError(_ message: String)
    func logCritical(_ message: String)
}
