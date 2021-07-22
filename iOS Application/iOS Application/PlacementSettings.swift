//
//  select model setting +
//
//
//  PlacementSettings.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/06.
//

import SwiftUI
import RealityKit
import Combine

class PlacementSettings: ObservableObject {
    
    // When the user selects a model in BrowseView, this property is set
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("Setting selectedModel to \(String(describing: newValue?.name))") // select model setting -> 배치 전에 선택된 모델 세팅
        }
    }
    // When the user taps confirm in PlacementView, the value of selectedModel is assigned to confirmModel
    @Published var confirmedModel: Model? {
        willSet(newValue) {
            guard let model = newValue else {
                print("Clearing confirmedModel") // 배치 후 clearing model
                return
            }
            print("Setting confirmedModel to \(model.name)") // 배치 준비
            
            self.recentlyPlaced.append(model)
        }
    }
    
    // This property retains a record of placed models in the scene. The last element in the array is the most recently placed model.
    @Published var recentlyPlaced: [Model] = []
    
    // This property retains the cancellable objects for our SceneEvents.Update subscriber
    var sceneObserver: Cancellable?
}
