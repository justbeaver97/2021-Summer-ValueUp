//
//  
//
//
//  ContentView.swift
//  iOS Application
//
//  Created by 저스트비버 on 2021/07/06.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @State private var isControlsVisible: Bool = true
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false // initialize button -> arview만 보임
    
    var body: some View {
        ZStack(alignment: .bottom) { // zstack -> 뷰들을 중첩시켜 줌
            ARViewContainer()
            
            if self.placementSettings.selectedModel == nil {
                ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings)
            } else {
                PlacementView() // selected model이 존재할 경우.
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable{
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    
    //UIViewRepresentable은 2개의 func를 필수적으로 지녀야함 - makeUIView, updateUIView
    func makeUIView(context: Context) -> CustomARView { // swiftui에서 나타낼 기본 뷰
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
        
        //subscribe to SceneEvents.Update
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            // TODO: Call update scene methods
            self.updateScene(for: arView) // update가 발생할 때 뷰
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        // Only display focusEntity when the user has selected a model for placement
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model to scene if confirmed for placement
        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
            // TODO: Call place method
            self.place(modelEntity, in: arView)
            
            self.placementSettings.confirmedModel = nil
        }
    }
    
    private func place(_ modelEntity: ModelEntity, in arView: ARView){
        // 1.Clone modelEntity. This creates an identical copy of modelEntity and references the same model. This also allows us to have multiple models of the same assest in our scene.
        let clonedEntity = modelEntity.clone(recursive: true)
        
        // 2.Enable translation and roation gestures.
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        
        // 3.Create an anchorEntity and add clonedEntity to the anchorEntity.
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        // 4.Add the anchorEntity to the arView.scene
        arView.scene.addAnchor(anchorEntity)
        
        print("Added modelEntity to scene.") // model placement 완료
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlacementSettings())
            .environmentObject(SessionSettings())
    }
}
