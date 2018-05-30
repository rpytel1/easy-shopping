//
//  AddProductViewController.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 26.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import UIKit

class AddProductViewController: UIViewController {
    var userLogin : String!

    @IBOutlet weak var productTextArea: UITextField!
    @IBOutlet weak var quantityTextArea: UITextField!
    @IBOutlet weak var addProductButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Add view controller"+userLogin)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func addProduct(_ sender: Any) {
        print("Add product!")
        let url = URL(string: "http://192.168.1.3:8000/addProduct")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters = ["product": productTextArea.text!,"quantity":quantityTextArea.text!,"owner":userLogin]
        print(parameters)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{return}
        do{
             let json = try JSONSerialization.jsonObject(with: httpBody, options: [])
            print(json)
        }catch{
            print(error)
        }
        request.httpBody = httpBody
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
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
