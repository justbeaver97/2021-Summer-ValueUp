//
//  Model.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/06.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: CaseIterable {
    case table
    case deco
    case tv
    case other
    
    var label: String {
        get {
            switch self {
            case .table:
                return "Tables"
            case .deco:
                return "Decorations"
            case .tv:
                return "TV"
            case .other:
                return "Others"
            }
        }
    }
}

class Model {
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellabe: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
    
    // TODO: Create a method to async load modelEntity
    func asyncLoadModelEntity() {
        let filename = self.name + ".usdz"
        
        self.cancellabe = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                
                switch loadCompletion {
                case .failure(let error): print("Unable to load modelEntity for \(filename). Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                self.modelEntity?.scale *= self.scaleCompensation
                
                print("modelEntity for \(self.name) has been loaded.")
            })
    }

}

struct Models {
    var all: [Model] = []
    
    init() {
        // chair
        let chair_swan = Model(name:"chair_swan", category: .table, scaleCompensation: 0.32/100)
        
        self.all += [chair_swan]
        
        // deco
        let fender_stratocaster = Model(name: "fender_stratocaster", category: .deco, scaleCompensation: 0.32/100)
        let cup_saucer_set = Model(name:"cup_saucer_set", category: .deco, scaleCompensation: 0.32/100)
        let gramophone = Model(name:"gramophone", category: .deco, scaleCompensation: 0.32/100)
        
        self.all += [fender_stratocaster, cup_saucer_set, gramophone]
    
        // tv
        let tv_retro = Model(name:"tv_retro", category: .tv, scaleCompensation: 0.32/100)
        
        self.all += [tv_retro]
        
        //others
        let pot_plant = Model(name:"pot_plant", category: .other, scaleCompensation: 0.32/100)
        let flower_tulip = Model(name:"flower_tulip", category: .other, scaleCompensation: 0.32/100)
        
        self.all += [pot_plant, flower_tulip]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter( { $0.category == category } )
    }
}
