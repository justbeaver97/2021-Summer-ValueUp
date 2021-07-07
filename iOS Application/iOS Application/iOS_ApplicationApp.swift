//
//  iOS_ApplicationApp.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/06.
//

import SwiftUI

@main
struct iOS_ApplicationApp: App {
    @StateObject var placementSettings = PlacementSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(placementSettings)
        }
    }
}
