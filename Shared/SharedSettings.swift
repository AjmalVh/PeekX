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
    
    static func load() -> SharedSettings {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: "settings"),
              let settings = try? JSONDecoder().decode(SharedSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "settings")
        }
    }
}
