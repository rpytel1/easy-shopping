//
//  ListViewController.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 26.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import UIKit 
class ListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var userLogin : String!
    var fetchedList = [ListEntry]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("List view controller"+userLogin)
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchList()
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let listEntry = fetchedList[indexPath.row]
        cell?.backgroundColor=departmentToColor[listEntry.type]
        cell?.textLabel?.text = listEntry.product
        cell?.detailTextLabel?.text = listEntry.quantity
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            print(indexPath.row)
            deleteRow(listEntry:fetchedList[indexPath.row])
            fetchedList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at:[indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToAddProduct(_ sender: Any) {
        performSegue(withIdentifier: "addViewSegue", sender: userLogin)
    }
    
    @IBAction func goToSendFriend(_ sender: Any) {
        performSegue(withIdentifier: "sendViewSegue", sender: userLogin)
    }
    func fetchList(){
        fetchedList=[ListEntry]()
        let url = URL(string: "http://192.168.1.3:8000/getWholeList/"+userLogin)!
        _ = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSArray
                print(json)
                for eachFetchedListEntry in json{
                    let eachListEntry = eachFetchedListEntry as! [String:Any]

                    let product = eachListEntry["product"] as! String
                    let quantity = eachListEntry["quantity"] as! String
                    let id = eachListEntry["id"] as! CLong
                    self.fetchedList.append(ListEntry(product: product, quantity: quantity, id: id))
                }
                OperationQueue.main.addOperation {
                    self.orderList()
                    self.tableView.reloadData()}
            }catch{
                print(error)
            }
        }.resume()
    }
    func deleteRow(listEntry: ListEntry){
        let url = URL(string: "http://192.168.1.3:8000/deleteProduct")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters = ["product": listEntry.product,"quantity":listEntry.quantity ,"id":listEntry.id ,"owner":userLogin] as [String : Any]
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
    
    @IBAction func photoChange(_ sender: Any) {
        performSegue(withIdentifier: "cameraViewSegue", sender: userLogin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addViewSegue" {
            let addViewController = segue.destination as! AddProductViewController
            let login = sender as! String
            addViewController.userLogin = login
        }
        if segue.identifier == "sendViewSegue" {
            let sendViewController = segue.destination as! SendFriendViewController
            let login = sender as! String
            sendViewController.userLogin = login
        }
        if segue.identifier == "cameraViewSegue"{
            let sendViewController = segue.destination as! CameraViewController
            let login = sender as! String
            sendViewController.userLogin = login
        }
    }
    
    func orderList(){
        var vegetables = [ListEntry]()
        var meats = [ListEntry]()
        var cheeses = [ListEntry]()
        var chemicals = [ListEntry]()
        var bread = [ListEntry]()
        var other = [ListEntry]()

        for elem in fetchedList{
            if checkIfContains(listEntry: elem, list: cheeseProducts, type: Department.CHEESE){
                cheeses.append(elem)
            }
            if checkIfContains(listEntry: elem, list: meatProducts, type: Department.MEAT){
                meats.append(elem)
            }
            if checkIfContains(listEntry: elem, list: vegetablesProducts, type: Department.VEGETABLES){
                vegetables.append(elem)
            }
            if checkIfContains(listEntry: elem, list: chemicalsProducts, type: Department.CHEMICALS){
                chemicals.append(elem)
            }
            
            if checkIfContains(listEntry: elem, list: breadProducts, type: Department.BREAD){
                bread.append(elem)
            }
            
            if(elem.type == Department.OTHER){
              other.append(elem)
            }
        }
        fetchedList = [ListEntry]()
        fetchedList.append(contentsOf: vegetables)
        fetchedList.append(contentsOf: meats)
        fetchedList.append(contentsOf: cheeses)
        fetchedList.append(contentsOf: chemicals)
        fetchedList.append(contentsOf: bread)
        fetchedList.append(contentsOf: other)
    }
    
    func checkIfContains(listEntry: ListEntry ,list : [String],type: Department)-> Bool{
        for elem in list{
            if(listEntry.product.containsIgnoringCase(elem)){
                listEntry.type = type
                return true
            }
        }
        return false
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
public class ListEntry{
    public var id : CLong
    public var product : String
    public var quantity : String
    public var type : Department
    init(product: String, quantity : String, id: CLong){
        self.product = product
        self.quantity = quantity
        self.id = id
        self.type = Department.OTHER
    }
}

//// COMMON UTILS
public var departmentToColor = [Department.CHEESE:UIColor.orange, Department.MEAT : UIColor.red, Department.BREAD : UIColor.yellow, Department.CHEMICALS:UIColor.blue, Department.VEGETABLES:UIColor.green, Department.OTHER : UIColor.white]

public var cheeseProducts=["ser","cheese","twarog","twaróg","jogurt"]

public var meatProducts = ["szynka","wendlina","piers","chicken","wołowoina","stek","steak"]

public var breadProducts = ["chleb","bread","bułka","bulka"]

public var vegetablesProducts = ["tomato","pomidor","ziemniak","potato"]

public var chemicalsProducts = ["płyn","proszek","vanish"]

extension String{
    func containsIgnoringCase(_ find: String)->Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
public enum Department{
    case CHEESE
    case MEAT
    case BREAD
    case CHEMICALS
    case VEGETABLES
    case OTHER
}
