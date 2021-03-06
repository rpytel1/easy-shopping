//
//  ViewController.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 21.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view controller")

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginToApp(_ sender: Any) {
        print("Add product!")
        let url = URL(string: "http://192.168.1.3:8000/login")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters = ["login": loginTextfield.text!,"password":passwordTextField.text!]
        print(parameters)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{return}
        request.httpBody = httpBody
        var login = loginTextfield.text!
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
            let canPerformSegue = Bool(responseString!)!
            if(canPerformSegue){
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "listViewSegue",sender: login)
                }
            }
        }
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listViewSegue" {
            let listViewController = segue.destination as! ListViewController
            let login = sender as! String
            listViewController.userLogin = login
        }
    }

}

