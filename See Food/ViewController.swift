//
//  ViewController.swift
//  See Food
//
//  Created by protector on 1/17/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't conver to CIImage")
            }
            detectImage(image: ciImage)
        }
        
        
    }
    
    func detectImage(image: CIImage) {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let result = request.results as? [VNClassificationObservation] else {
                    fatalError("Model Failed to process image")
                }
                if let firstResult = result.first {
                    self.navigationItem.title = firstResult.identifier
                    var alert = UIAlertController()
                    alert.title = firstResult.identifier
                    alert.present(self, animated: true)
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            
            do {
                try handler.perform([request])
            } catch {
                var alert = UIAlertController()
                alert.title = "Error!!!"
                alert.present(self, animated: true)
            }
        } catch {
            var alert = UIAlertController()
            alert.title = "Error!!!"
            alert.present(self, animated: true)
        }
    }


    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
}

