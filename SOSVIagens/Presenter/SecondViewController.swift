//
//  SecondViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 24/04/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//
import CoreTelephony
import UIKit
import Firebase
import FirebaseDatabase
import SwiftIcons

class SecondViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var numberstbl: UITableView!
    var goverment = [Emergency]()
    var emergency = [Emergency]()
    var assurance = [Emergency]()
    var sections = [Section]()
    
    var ref:DatabaseReference?
    
    @IBOutlet weak var navbar: UINavigationBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchnumber(search: searchBar.text!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadNumbers()
    }
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ref?.keepSynced(true)
        numberstbl.delegate = self
        numberstbl.dataSource = self
        searchbar.delegate = self
        
        self.sections.append(Section(title: "Números de emergência",items: [Emergency]()))
        self.sections.append(Section(title: "Seguradoras",items: [Emergency]()))
        self.sections.append(Section(title: "Órgãos reguladores",items: [Emergency]()))
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navbar.setValue(true, forKey: "hidesShadow")
        if(sections.count == 0){
            print("Seções nao foram criadas")
            self.sections.append(Section(title: "Números de emergência",items: [Emergency]()))
            self.sections.append(Section(title: "Seguradoras",items: [Emergency]()))
            self.sections.append(Section(title: "Órgãos reguladores",items: [Emergency]()))
            loadNumbers()
            return
        }else{
            print("Sections ")
            dump(sections)
            loadNumbers()
        }
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.sections.count
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let number = sections[indexPath.section].items[indexPath.row]
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "IdentificationCell") as? TableViewCell else{
            return UITableViewCell()
            
        }
        cell.textLabel!.text = number.identification
        cell.detailTextLabel!.text = number.number
        
        switch number.type {
        case "Seguradora":
            cell.imageView?.setIcon(icon: .emoji(.shield),textColor: .systemBlue)
        case "Órgão regulador":
            cell.imageView?.setIcon(icon: .emoji(.building),textColor: cell.textLabel!.textColor)
        default:
            cell.imageView?.setIcon(icon: .emoji(.exclamationMark),textColor: .red)
            
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let number = sections[indexPath.section].items[indexPath.row]
        print("ligar para " + number.identification + "(" + number.number+")")
        call(phoneNumber: number.number)
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    @IBOutlet weak var results: UILabel!
    @IBOutlet weak var progressview: UIActivityIndicatorView!
    
    func searchnumber(search: String){
        self.progressview.startAnimating()
        self.emergency.removeAll()
        self.assurance.removeAll()
        self.goverment.removeAll()
        
        self.ref!.child("numbers")
            .queryOrdered(byChild: "tipo")
            .observe(.childAdded, with:  { (snapshot) in

                let number = self.buildemergency(snapshot: snapshot)
                if(number.number.lowercased().contains(search.lowercased())
                    ||
                    number.identification.lowercased().contains(search.lowercased())
                    ||
                    number.type.lowercased().contains(search.lowercased())){
                    
                    
                    if(number.type.elementsEqual("Emergência")){
                        self.emergency.append(number)
                    }else if(number.type.elementsEqual("Seguradora")){
                        self.assurance.append(number)
                    }else{
                        self.goverment.append(number)
                        
                    }
                }
                
            })
        self.showresults()
    }
    
    
    
    func isequal(search: String,comparision: String) -> Bool {
          let result: ComparisonResult = search.compare(comparision, options: NSString.CompareOptions.caseInsensitive)

          if result == .orderedSame {
              return true
          }
          return false
      }
    
    
    func call(phoneNumber: String){
        
        let phoneNumber = String(phoneNumber.filter {$0 != " "})
        if UIApplication.shared.canOpenURL(URL(string: "tel://\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))")!) {
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier: CTCarrier? = networkInfo.subscriberCellularProvider
            let code: String? = carrier?.mobileNetworkCode
            let uri = URL(string: "tel://" + phoneNumber)
            if (code != nil) {
                UIApplication.shared.open(uri!, options: [:], completionHandler: nil)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 1.5, animations: {
               cell.contentView.alpha = 1
           })
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sections[section].title
    }
    
    func loadNumbers(){
        self.progressview.startAnimating()
        self.emergency.removeAll()
        self.assurance.removeAll()
        self.goverment.removeAll()
        print("loading numbers")
        self.searchbar.showsCancelButton = false
        
        self.ref!.child("numbers")
            .queryOrdered(byChild: "tipo")
            .observe(.childAdded, with:  { (snapshot) in
                print("There are " + String(self.sections.count) + " sections")
                 let number = self.buildemergency(snapshot: snapshot)
                if(number.type.elementsEqual("Emergência")){
                    self.emergency.append(number)
                }else if(number.type.elementsEqual("Seguradora")){
                    self.assurance.append(number)
                }else{
                    self.goverment.append(number)
                }
                
            })
        showresults()
        
        
        
        
        
        
        
    }
    
    func showresults(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { //
            print("Emergency numbers " + String(self.emergency.count))
            print("Assurance numbers " + String(self.assurance.count))
            print("Goverment numbers " + String(self.goverment.count))
            
                self.sections[0].items = self.alphabeticlist(nlist: self.emergency)!
                self.sections[1].items = self.alphabeticlist(nlist: self.assurance)!
                self.sections[2].items = self.alphabeticlist(nlist: self.goverment)!
                self.dismissKeyboard()

                 dump(self.sections)
                
            self.progressview.stopAnimating()
            self.dismissKeyboard()
            self.numberstbl.reloadData()
            if(self.searchresult()){
                self.results.isHidden = true
                self.numberstbl.isHidden = false
            }else{
                self.results.text = "Nenhum resultado encontrado"
                self.results.isHidden = false
                self.numberstbl.alpha = 0
                self.numberstbl.isHidden = true
                
                UIView.animate(withDuration: 2.5, animations: {
                    self.numberstbl.alpha = 1
                })
            }
            
            
        }
    }
    
    
    
    func searchresult() -> Bool{
        if(self.sections[0].items.count > 0){
            return true
        }else if(self.sections[1].items.count > 0){
            return true
        }else if(self.sections[2].items.count > 0){
            return true
        }
        return false
        
    }
    
    func alphabeticlist(nlist: [Emergency]) -> [Emergency]?{
        
        let orderedlist = nlist.sorted(by: { (item1, item2) -> Bool in
            return item1.identification.compare(item2.identification) == ComparisonResult.orderedAscending
        })
        
        return orderedlist
    }
    
    func buildemergency(snapshot: DataSnapshot) -> Emergency{
        let tel = snapshot.childSnapshot(forPath: "telefone").value as! String
        let identification = snapshot.childSnapshot(forPath: "ident").value as! String
        let tipo = snapshot.childSnapshot(forPath: "tipo").value as! String
        let key = snapshot.key
        return  Emergency(key: key,number:tel,type:tipo,identification:identification)
        
    }
}

