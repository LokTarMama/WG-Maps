//
//  GolfCartPathApp.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/10/26.
//

import SwiftUI
import CoreData

@main
struct GolfCartPathApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
