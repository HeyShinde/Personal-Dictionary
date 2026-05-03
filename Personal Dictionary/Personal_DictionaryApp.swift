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
        Window("Personal Dictionary", id: "main") {
            ContentView()
                .onAppear {
                    appDelegate.serviceProvider.modelContext = sharedModelContainer.mainContext
                }
        }
        .modelContainer(sharedModelContainer)
        
        // Menu Bar Quick Add
        MenuBarExtra("Personal Dictionary", systemImage: "book.closed.fill") {
            MenuBarContentView(
                launchAtLogin: $launchAtLogin,
                setLaunchAtLogin: setLaunchAtLogin
            )
            .modelContainer(sharedModelContainer)
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

// MARK: - Menu Bar Content
struct MenuBarContentView: View {
    @Binding var launchAtLogin: Bool
    var setLaunchAtLogin: (Bool) -> Void
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            QuickAddMenuView()
            
            Divider()
                .padding(.vertical, 4)
            
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
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "main")
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
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider = ServiceProvider()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.servicesProvider = serviceProvider
        NSUpdateDynamicServices()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when window is closed — keep menu bar alive
        // Hide from dock when no windows visible
        NSApp.setActivationPolicy(.accessory)
        return false
    }
}
