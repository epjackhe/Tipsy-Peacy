//
//  Tipsy_PeacyApp.swift
//  Tipsy Peacy
//
//  Created by Jack on 8/10/25.
//

import SwiftUI

@main
struct Tipsy_PeacyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
