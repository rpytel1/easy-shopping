//
//  SendFriendViewController.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 26.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import UIKit

class SendFriendViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var userLogin : String!
    var userList = [String]()
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        print("Send view controller"+userLogin)
        fetchAllUser()


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userList[row]
    }
    
    func fetchAllUser(){
        userList=[String]()
        let url = URL(string: "http://192.168.1.3:8000/getAllUser")!
        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSArray
                print(json)
                for eachFetchedUser in json{
                    let eachUser = eachFetchedUser as! String
                    print(eachUser)
                    
                    if(eachUser==self.userLogin){
                    }else{
                        self.userList.append(eachUser)
                    }
                }
                print(self.userList)
                
                OperationQueue.main.addOperation {self.pickerView.reloadComponent(0)}
            }catch{
                print(error)
            }
            }.resume()
    }
    
    @IBAction func sendToFriend(_ sender: Any) {
        var chosenUser = userList[pickerView.selectedRow(inComponent: 0)]
        print(chosenUser)
        let url = URL(string: "http://192.168.1.3:8000/sendList")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters = ["sender": userLogin,"receiver":chosenUser]
        print(parameters)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{return}

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
            let canPerformSegue = Bool(responseString!)!
            if(canPerformSegue){
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "listViewFriend",sender: self.userLogin)
                }
            }
            
        }
        task.resume()
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listViewFriend" {
            let listViewController = segue.destination as! ListViewController
            let login = sender as! String
            listViewController.userLogin = login
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
