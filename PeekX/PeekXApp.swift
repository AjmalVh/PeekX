//
//  PeekXApp.swift
//  PeekX
//
//  Copyright © 2025 ALTIC. All rights reserved.
//

import SwiftUI
import AppKit
import UserNotifications

@main
struct PeekXApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Window("PeekX Preferences", id: "preferences") {
            SettingsView()
                .frame(minWidth: 480, minHeight: 380)
        }
        .windowResizability(.contentSize)
    }
}

struct SettingsView: View {
    @State private var settings = SharedSettings.load()
    @State private var showSavedAlert = false
    @State private var statusMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PeekX Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            GroupBox("Preview Window Dimensions") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Width:")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: $settings.previewWidth, in: 700...1600, step: 20)
                        Text("\(Int(settings.previewWidth)) px")
                            .monospacedDigit()
                            .frame(width: 65, alignment: .trailing)
                    }
                    HStack {
                        Text("Height:")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: $settings.previewHeight, in: 500...1200, step: 20)
                        Text("\(Int(settings.previewHeight)) px")
                            .monospacedDigit()
                            .frame(width: 65, alignment: .trailing)
                    }
                }
                .padding(8)
            }
            
            GroupBox("Folder Analysis") {
                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Calculate folder size recursively", isOn: $settings.calculateFolderSizeRecursively)
                    Text("Calculates total file size across all nested subfolders in the background.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }
            
            GroupBox("Maintenance") {
                HStack(spacing: 12) {
                    Button("Reset Split Divider") {
                        settings.savedSplitPosition = nil
                        settings.save()
                        statusMessage = "Split divider position reset."
                    }
                    
                    Button("Refresh Quick Look Cache") {
                        AppDelegate.refreshQuickLookExtension()
                        statusMessage = "Quick Look cache refreshed successfully."
                    }
                }
                .padding(8)
            }
            
            if let msg = statusMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Save Settings") {
                    settings.save()
                    statusMessage = "Settings saved successfully."
                    showSavedAlert = true
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .alert("Settings Saved", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        requestNotificationPermission()
        checkAndRefreshExtensionIfNeeded()
        
        if CommandLine.arguments.contains("--register") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { _, _ in }
    }
    
    private func checkAndRefreshExtensionIfNeeded() {
        let defaults = UserDefaults.standard
        let lastVersionKey = "PeekXLastLaunchedVersion"
        
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return
        }
        
        let currentFullVersion = "\(currentVersion).\(currentBuild)"
        let lastVersion = defaults.string(forKey: lastVersionKey)
        
        if lastVersion != currentFullVersion {
            AppDelegate.refreshQuickLookExtension()
            defaults.set(currentFullVersion, forKey: lastVersionKey)
            
            if lastVersion != nil {
                showUpdateNotification()
            }
        }
    }
    
    static func refreshQuickLookExtension() {
        let resetTask = Process()
        resetTask.launchPath = "/usr/bin/qlmanage"
        resetTask.arguments = ["-r", "cache"]
        try? resetTask.run()
        resetTask.waitUntilExit()
        
        let killTask = Process()
        killTask.launchPath = "/usr/bin/killall"
        killTask.arguments = ["quicklookd"]
        try? killTask.run()
    }
    
    private func showUpdateNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "PeekX Updated"
            content.body = "Quick Look extension has been refreshed"
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
            
            center.add(request) { _ in }
        }
    }
}
