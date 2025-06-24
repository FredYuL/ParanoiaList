//
//  ParanoiaListApp.swift
//  ParanoiaList
//
//  Created by Yu Liang on 6/21/25.
//

import SwiftUI

@main
struct ParanoiaListApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName: "checkmark.circle")
                        Text("Checklist")
                    }
                CBTTipsView()
                    .tabItem {
                        Image(systemName: "lightbulb")
                        Text("CBT Tips")
                    }
            }
        }
    }
}
