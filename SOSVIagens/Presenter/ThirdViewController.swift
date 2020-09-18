//
//  ThirdViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 24/04/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//
import CoreTelephony

import UIKit
import FirebaseDatabase

class ThirdViewController: UIViewController, UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {
    var Result = [Road]()
    var calledroad:Road!
     var ref:DatabaseReference?
    @IBOutlet weak var searchresult: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Result.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as? RoadTableViewCell else{
            return UITableViewCell()
            
        }
        cell.textLabel!.text = Result[indexPath.row].road as String
        cell.detailTextLabel!.text = Result[indexPath.row].concess as String + "(" + Result[indexPath.row].phone + ")"
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let commentViewController = segue.destination as? CommentViewController,
            let index = searchresult.indexPathForSelectedRow?.row
            else {
                return
        }
       commentViewController.road = Result[index]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        calledroad = Result[indexPath.row]
        print("ligar para " + Result[indexPath.row].phone)
        print("ligou para  concessionaria " + calledroad.concess)

        let cs = CharacterSet.init(charactersIn: "-")

        call(phoneNumber: Result[indexPath.row].phone.trimmingCharacters(in: cs))

        call(phoneNumber: Result[indexPath.row].phone.trimmingCharacters(in: .whitespaces))
    }
    
    
    
    
    func call(phoneNumber: String){
        let phoneNumber = String(phoneNumber.filter {$0 != " "})
        print("ligar para " + phoneNumber)
        if UIApplication.shared.canOpenURL(URL(string: "tel://\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)))")!) {
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier: CTCarrier? = networkInfo.subscriberCellularProvider
            let code: String? = carrier?.mobileNetworkCode
            if (code != nil) {
                UIApplication.shared.openURL((URL(string: "tel://\(phoneNumber)")!))
            }
            else {
                let alert = UIAlertController(title: "SIM Card not detected", message: "No SIM Card founded on your phone, it's imposssible to make a phone call in your device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
        else {
            let alert = UIAlertController(title: "Device does not support phone calls", message: "It seems your device does not support phone calls, we can't help you", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("pesquisa")
        SearchDatabase(search: searchbar.text!)
    }
    
    func SearchDatabase(search: String){
        self.Result.removeAll()

        self.ref?.child("rodovias")
            .queryOrdered(byChild: "rodovia")
            .queryStarting(atValue: search)
            .queryEnding(atValue: search +  "\u{f8ff}")
            .observe(.childAdded, with:  { (snapshot) in
                let phone = snapshot.childSnapshot(forPath: "telefone").value as! String
                let concess = snapshot.childSnapshot(forPath: "concessionaria").value as! String
                let roadname = snapshot.childSnapshot(forPath: "rodovia").value as! String
                if let r = snapshot.value as? Dictionary<String, AnyObject> {
                    let road = Road()
                    road.setValuesForKeys(r)
                    self.Result.append(road)
                }
                
                self.searchresult.reloadData()

        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchbar.backgroundImage = UIImage()

        self.ref = Database.database().reference()
        self.searchresult.delegate = self
        self.searchresult.dataSource = self
         // Do any additional setup after loading the view.
    }
    

    

}

