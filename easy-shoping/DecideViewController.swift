//
//  DecideViewController.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 29.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import UIKit

class DecideViewController: UIViewController, UITableViewDataSource {
    var userLogin : String!
    var fetchedList = [ListEntry]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Moja lista", fetchedList.count )
        print("List view controller"+userLogin)
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = fetchedList[indexPath.row].product
        cell?.detailTextLabel?.text = fetchedList[indexPath.row].quantity
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            print(indexPath.row)
            fetchedList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at:[indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func addProducts(_ sender: Any) {
        print("adding products")
        
        let url = URL(string: "http://192.168.1.3:8000/addProducts")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var parameters = [[String:Any]]()
        for item in fetchedList{
            let parameter = ["product":item.product,"quantity":item.quantity,"owner":userLogin]
            parameters.append(parameter)
        }
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
