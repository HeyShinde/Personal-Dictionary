//
//  Personal_DictionaryApp.swift
//  Personal Dictionary
//
//  Created by Antigravity on 03/05/26.
//

import SwiftUI
import SwiftData

@main
struct Personal_DictionaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
            QuickAddMenuView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider = ServiceProvider()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.servicesProvider = serviceProvider
        NSUpdateDynamicServices()
    }
}
