//
//  CustomARView.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/06.
//

import RealityKit
import ARKit
import FocusEntity

class CustomARView: ARView {    //CustomARView is subclass of ARView
    var focusEntity: FocusEntity?   //? : optional
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
        
        configure()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
    }
}
