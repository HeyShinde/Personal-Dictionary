//
//  Personal_DictionaryApp.swift
//  Personal Dictionary
//
//  Created by Antigravity on 03/05/26.
//

import SwiftUI
import SwiftData
import ServiceManagement

@main
struct Personal_DictionaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WordEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    appDelegate.serviceProvider.modelContext = sharedModelContainer.mainContext
                }
        }
        .modelContainer(sharedModelContainer)
        
        // Menu Bar Quick Add
        MenuBarExtra("Personal Dictionary", systemImage: "book.closed.fill") {
            VStack(spacing: 0) {
                QuickAddMenuView()
                    .modelContainer(sharedModelContainer)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Settings row
                HStack {
                    Toggle("Launch at Login", isOn: Binding(
                        get: { launchAtLogin },
                        set: { newValue in
                            launchAtLogin = newValue
                            setLaunchAtLogin(newValue)
                        }
                    ))
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                HStack {
                    Button("Open Dictionary") {
                        NSApp.activate(ignoringOtherApps: true)
                        if let window = NSApp.windows.first(where: { $0.title.contains("Personal Dictionary") || $0.isKeyWindow }) {
                            window.makeKeyAndOrderFront(nil)
                        } else {
                            // Open a new window
                            NSApp.sendAction(#selector(NSDocumentController.newDocument(_:)), to: nil, from: nil)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "register" : "unregister") login item: \(error)")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider = ServiceProvider()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.servicesProvider = serviceProvider
        NSUpdateDynamicServices()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Re-open main window when clicking dock icon
            for window in sender.windows {
                if window.canBecomeMain {
                    window.makeKeyAndOrderFront(self)
                    return true
                }
            }
        }
        return true
    }
}
