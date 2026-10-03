//
//  SharedSettings.swift
//  PeekX
//
//  Copyright © 2025 ALTIC. All rights reserved.
//

import Foundation

struct SharedSettings: Codable, Equatable {
    var showHiddenFiles: Bool
    var showFileTypes: Bool
    var showRecentFiles: Bool
    var showLargestFiles: Bool
    var maxRecentFiles: Int
    var maxLargestFiles: Int
    var previewWidth: Double
    var previewHeight: Double
    var savedSplitPosition: Double?
    var calculateFolderSizeRecursively: Bool
    
    static let `default` = SharedSettings(
        showHiddenFiles: false,
        showFileTypes: true,
        showRecentFiles: true,
        showLargestFiles: true,
        maxRecentFiles: 10,
        maxLargestFiles: 10,
        previewWidth: 900,
        previewHeight: 600,
        savedSplitPosition: nil,
        calculateFolderSizeRecursively: true
    )
    
    static let appGroupIdentifier = "group.altic.PeekX"
    
    static func load() -> SharedSettings {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return .default
        }
        
        guard let data = userDefaults.data(forKey: "settings"),
              let settings = try? JSONDecoder().decode(SharedSettings.self, from: data) else {
            return .default
        }
        
        return settings
    }
    
    func save() {
        guard let userDefaults = UserDefaults(suiteName: SharedSettings.appGroupIdentifier) else {
            return
        }
        
        if let data = try? JSONEncoder().encode(self) {
            userDefaults.set(data, forKey: "settings")
        }
    }
}
