//
//  거리재기 모드
//
import UIKit
//import SceneKit
import ARKit

final class ViewController6: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK: - Properties
    
    private var dotNodes = [SCNNode]()
    private var textNode = SCNNode() // Scenekit
    
    public var public_distance = 0 // 거리
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController6")
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] // featurePoints -> SceneView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController7 {
            let nextVC = segue.destination as? ViewController7
            nextVC?.public_distance = public_distance //  잰 거리 전달 -> android intent
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // 사용자가 거주하는 실제 세계를 추적하고 가상 콘텐츠를 배치할 좌표 공간과 일치시킴
        // 물체, 이미지, 조명 조건 인식 및 반응하는 arkit 기능 제공 -> 후면 카메라
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // view가 계층에 추가되고 화면에 표시되기 직전에 수행 -> 화면에 나타날 때마다 수해하는 작업
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    
    private func addDot(at hitResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material] // Dot
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        dotNodes.append(dotNode)
        sceneView.scene.rootNode.addChildNode(dotNode) // Dot을 배치하기 위헤 anchor과 anchorNode를 scene에 배치
        
        if dotNodes.count >= 2 {
            calculate() // 배치된 dot이 2가 되면 거리를 계산
        }
    }
    
    private func calculate() { // 거리 계산하는 함수
        let startPosition = dotNodes[0].position
        let endPosition = dotNodes[1].position // 각 dot의 position을 불러와 start, end에 저장
        print(startPosition)
        print(endPosition)
//        distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        let distance = sqrt(
            pow(endPosition.x - startPosition.x, 2) +
            pow(endPosition.y - startPosition.y, 2) +
            pow(endPosition.z - startPosition.z, 2)
        )
        print(distance*100,"cm")
        public_distance = Int(distance*100) // m단위인 distance cm(int)로 변환하여 저장
        let textFormatted = String(format: "%.0f", (abs(distance*100))) + " cm"
        if (public_distance > 50) {
            showAlertAble() // 배치가 가능합니다.
        } else {
            showAlertUnAble() // 배치가 불가능합니다 -> 거리 재측정
        }
        updateText(text: textFormatted, atPosition: endPosition)
    }
    
    private func updateText(text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    private func refreshDotNodes() { // 배치한 dotnode를 초기화
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            textNode.removeFromParentNode()
        } // Parent 관계 모두 Remove
    }
    
    func showAlertAble() {
        let alert = UIAlertController(title: "", message: "배치가 가능합니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { action in
            print("tapped dismiss")
        }))
        present(alert, animated: true)
    }
    func showAlertUnAble() {
        let alert = UIAlertController(title: "", message: "배치가 불가능합니다. 다른 장소를 선택하세요. (가구 길이: 50cm)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { action in
            print("tapped dismiss")
        }))
        present(alert, animated: true)
    }
}

// MARK: - ARSCNViewDelegateMethods

extension ViewController6: ARSCNViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        refreshDotNodes()
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else { return }
            let hitTestResults = sceneView.session.raycast(query)
            guard let hitResult = hitTestResults.first else {
                print("No surface detected")
                return
            }
            addDot(at: hitResult)
        }
    }
}
