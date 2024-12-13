//
//  SystemLoggerAdapter.swift
//  PulseEco
//
//  Created by Nikola Jankovikj on 3.12.24.
//

import Foundation
import os

class SystemLoggerAdapter: LoggerProtocol {
    private let logger: Logger
    
    init(subSystem: String = Bundle.main.bundleIdentifier ?? "com.netcetera.skopjepulse", category: String = "default") {
        self.logger = Logger(subsystem: subSystem, category: category)
    }
    
    func logDebug(_ message: String) {
        logger.debug("\(message)")
    }
    
    func logInfo(_ message: String) {
        logger.info("\(message)")
    }
    
    func logError(_ message: String) {
        logger.error("\(message)")
    }
    
    func logCritical(_ message: String) {
        logger.critical("\(message)")
    }
}
