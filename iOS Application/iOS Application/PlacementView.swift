//
// select model -> Placement model setting
//
//
//  PlacementView.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/06.
//

import SwiftUI

struct PlacementView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        HStack {
            
            Spacer()
            PlacementButton(systemIconName: "xmark.circle.fill") {
                print("Cancel Placement button pressed") // cancel
                self.placementSettings.selectedModel = nil // model select initialized
            }
            
            Spacer()
            PlacementButton(systemIconName: "checkmark.circle.fill") {
                print("Confirm Placement button pressed") // confirm
                
                self.placementSettings.confirmedModel = self.placementSettings.selectedModel // object placement
                self.placementSettings.selectedModel = nil // model select initialized
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct PlacementButton: View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75) // checkmark, xmark setting
    }
}
