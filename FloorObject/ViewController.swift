//
//  ViewController.swift
//  FloorObject
//
//  Created by JiniGuruiOS on 18/07/19.
//  Copyright © 2019 jiniguru. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var itmesCollection: UICollectionView!
    @IBOutlet weak var scenView: ARSCNView!
    let configuation = ARWorldTrackingConfiguration()
    var itemsArry = ["cup","vase","boxing","table"]
    var selectedItems:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configuation.planeDetection = .horizontal
        self.scenView.session.run(configuation)
        self.scenView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        self.gestureRecongnize()
        self.pinchGestureRecognization()
        self.longGestureRescognization()
        // Do any additional setup after loading the view.
    }
    
    func gestureRecongnize() {
        let tapguesture = UITapGestureRecognizer.init(target: self, action: #selector(tapONScenView))
        self.scenView.addGestureRecognizer(tapguesture)
    }
    
    func longGestureRescognization() {
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressOnScenView(sender:)))
        self.scenView.addGestureRecognizer(longGesture)
    }
    
    func pinchGestureRecognization() {
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pichOnScenView))
        self.scenView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func longPressOnScenView(sender:UILongPressGestureRecognizer) {
        let scenview = sender.view as! ARSCNView
        let location = sender.location(in: scenview)
        let hitTest = scenview.hitTest(location)
        if !hitTest.isEmpty {
            let firstResult = hitTest.first!
            let node = firstResult.node
            if sender.state == .began {
                let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotationAction)
                node.runAction(forever)
            }else if sender.state == .ended {
                node.removeAllActions()
            }
        }
    }
    @objc func pichOnScenView(sender:UIPinchGestureRecognizer) {
        let scenview = sender.view as! ARSCNView
        let location = sender.location(in: scenview)
        let hitTest = scenview.hitTest(location)
        if !hitTest.isEmpty {
            let firstObj = hitTest.first!
            let node = firstObj.node
            let scalAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(scalAction)
            sender.scale = 1
            print(sender.scale)
        }
    }
    
    @objc func tapONScenView(sender:UITapGestureRecognizer){
        let scen = sender.view as! ARSCNView
        let location = sender.location(in: scen)
        let hitTest = scen.hitTest(location, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            print("Tap on horizontal")
            self.addItem(hitTestResult: hitTest.first!)
        }
    }
    
    func addItem(hitTestResult:ARHitTestResult){
        guard selectedItems != nil else{
            return
        }
        let scen = SCNScene.init(named: "Media.scnassets/\(selectedItems!).scn")
        let node = scen?.rootNode.childNode(withName: selectedItems!, recursively: false)
        
        if self.selectedItems! == "table" {
            self.centerPivot(for: node!)
        }
        
        let transform = hitTestResult.worldTransform
        let thirdPosition = transform.columns.3
        node?.position = SCNVector3(thirdPosition.x,thirdPosition.y,thirdPosition.z)
        self.scenView.scene.rootNode.addChildNode(node!)
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
}


//MARK: - Collection View delegate and dataSources -
extension ViewController: UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemsArry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.itmesCollection.dequeueReusableCell(withReuseIdentifier: "ItemsCollectionViewCell", for: indexPath) as! ItemsCollectionViewCell
        cell.backgroundColor = UIColor.orange
        cell.lblTitle.text = self.itemsArry[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.itmesCollection.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.green
        self.selectedItems = self.itemsArry[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.itmesCollection.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
    
    
}


extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
