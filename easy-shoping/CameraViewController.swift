//
//  CameraViewController.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 27.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import UIKit
class CameraViewController: UIViewController{

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var makePhotoButton: UIButton!
    let photoPickerController = UIImagePickerController()
    let libaryPickerController = UIImagePickerController()
    var userLogin: String!
    var fetchedList = [ListEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        photoPickerController.sourceType=UIImagePickerControllerSourceType.camera
        photoPickerController.delegate = self
        libaryPickerController.sourceType=UIImagePickerControllerSourceType.photoLibrary
        libaryPickerController.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func makePhoto(_ sender: Any) {
        present(photoPickerController, animated: true, completion: nil)
    }
    
    @IBAction func useLibary(_ sender: Any) {
        present(libaryPickerController, animated: true, completion: nil)
    }

    @IBAction func sendToEncode(_ sender: Any) {
        if let capturePhotoImage = self.photoView.image!.resized(withPercentage: 0.5) {
            if let imageData = UIImageJPEGRepresentation(capturePhotoImage,0.2) {
                let encodedImageData = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                var request = URLRequest(url: URL(string: "http://192.168.1.3:8000/upload")!)
                request.httpMethod = "POST"
                let postString = "image="+encodedImageData
                request.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSArray
                        print(json)
                        for eachFetchedListEntry in json{
                            let product = eachFetchedListEntry as! String
                            self.fetchedList.append(ListEntry(product: product, quantity: "", id: 0))
                        }
                        print(self.fetchedList.count)
                        OperationQueue.main.addOperation { self.performSegue(withIdentifier: "decideViewSegue",sender: self.fetchedList)}

                    }
                    catch{
                        print(error)
                    }
                }
                task.resume()
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "decideViewSegue" {
            let decideViewController = segue.destination as! DecideViewController
            let fetchedList = sender as! [ListEntry]
            decideViewController.userLogin = self.userLogin
            decideViewController.fetchedList = fetchedList
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        photoView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("camera has been closed")
    }
}
extension CameraViewController: UINavigationControllerDelegate {

}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

