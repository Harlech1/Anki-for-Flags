//
//  Anki_for_FlagsApp.swift
//  Anki for Flags
//
//  Created by Türker Kızılcık on 15.06.2025.
//

import SwiftUI

@main
struct Anki_for_FlagsApp: App {
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.context)
        }
    }
}
