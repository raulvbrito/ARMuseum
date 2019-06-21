//
//  ViewController.swift
//  ARMuseum
//
//  Created by Raul Brito on 19/06/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var paintings: [String: Painting] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
		
        UIApplication.shared.isIdleTimerDisabled = true
        loadPaintings()
    }
	
    func loadPaintings() {
		guard let url = Bundle.main.url(forResource: "paintings", withExtension: "json") else {return}
		guard let data = try? Data(contentsOf: url) else {return}
		guard let loadedPaintings = try? JSONDecoder().decode([String: Painting].self, from: data) else {return}
		paintings = loadedPaintings
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
		
		guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "paintings", bundle: nil) else {return}
		
		configuration.trackingImages = trackingImages
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
	
	
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
		guard let imageAnchor = anchor as? ARImageAnchor else {return nil}
		guard let image = imageAnchor.referenceImage.name else {return nil}
		guard let painting = paintings[image] else {
			return nil
		}
		
		
		let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
		plane.firstMaterial?.diffuse.contents = UIColor.clear
		
		let planeNode = SCNNode(geometry: plane)
		planeNode.eulerAngles.x = -.pi/2
		
		let node = SCNNode()
		node.addChildNode(planeNode)
		
		
		//Adicionando Texto
		let space: Float = 0.005

		let titleNode = getTextNode(painting.name, font: UIFont.boldSystemFont(ofSize: 10))
		titleNode.pivotOnTopLeft()
		titleNode.position.x += Float(plane.width/2) + space
		titleNode.position.y += Float(plane.height/2)
		planeNode.addChildNode(titleNode)
		
		
		let author = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.width / 8 * 5)
		author.firstMaterial?.diffuse.contents = UIImage(named: painting.authorPhoto)
		let authorNode = SCNNode(geometry: author)
		authorNode.pivotOnTopLeft()
		authorNode.position.y -= Float(plane.height/2) + space
		authorNode.position.x -= Float(plane.height/2)
		planeNode.addChildNode(authorNode)
		

		return node
	}
	
	func getTextNode(_ text: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
		let text = SCNText(string: text, extrusionDepth: 0)
		text.flatness = 0.15
		text.font = font
		if let maxWidth = maxWidth {
			text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
			text.isWrapped = true
		}
		let textNode = SCNNode(geometry: text)
		textNode.scale = SCNVector3(0.002, 0.002, 0.002)
		return textNode
	}
	
}

extension SCNNode {
	func pivotOnTopLeft() {
		pivot = SCNMatrix4MakeTranslation(boundingBox.min.x, boundingBox.max.y, 0)
	}
}
