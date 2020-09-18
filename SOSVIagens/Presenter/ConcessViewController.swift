//
//  ConcessViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 29/10/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import PullUpController
import CodableFirebase
class ConcessViewController: PullUpController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var noresults: UILabel!
     var ref = Database.database().reference()
    var concess = [Road]()
    var rootview:MapSceneViewController? = nil
    var closed = false
    var warned = false
    var expanded = false
    var founded = false
    var onaroad = false
    var searched = false
    
    
    @IBOutlet weak var container: UIVisualEffectView!
    @IBOutlet weak var progressview: UIActivityIndicatorView!
    @IBOutlet weak var scrollindicator: UIView!
    @IBOutlet weak var concesstable: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    
 
    override var pullUpControllerBounceOffset: CGFloat {
           return 15
       }
       
    
    
    override var pullUpControllerPreferredSize: CGSize {
        let frame = self.rootview?.view.safeAreaLayoutGuide.layoutFrame

        let screenSize: CGRect = UIScreen.main.bounds
        let size = frame?.size ?? screenSize.size
        //size.height = screenSize.height - 50
        return size
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return concess.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "ConcessCell") as? ConcessViewCell else{
            return UITableViewCell()
            
        }
        
        cell.concessname!.text = concess[indexPath.row].concessionaria + "(" + concess[indexPath.row].telefone + ")"
        cell.roadname!.text = concess[indexPath.row].rodovia
        cell.contentView.alpha = 0

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 1.5, animations: {
               cell.contentView.alpha = 1
           }) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchbar.delegate = self
        self.concesstable.delegate = self
        self.concesstable.dataSource = self
        self.scrollindicator.layer.cornerRadius = 5
  
    }
    
    
    
    func isaroad(endereco: String) -> Bool {
        let result: ComparisonResult = endereco.compare("rua", options: NSString.CompareOptions.caseInsensitive)

        if result == .orderedSame {
            return false
        }
        return true
    }
    
    
    @IBAction func showup(_ sender: Any) {
        self.slideup()
    }
    
    
    func slideup(){
    
        if(!founded){
            print("no roads where founded to make view expandable")
            self.preferredContentSize.height = self.preferredContentSize.height * 0.25
            
            return
        }
        
        if(expanded){
            let size = self.rootview?.mapview.frame.size;         self.pullUpControllerMoveToVisiblePoint(size!.height * 0.90, animated: true, completion: {
                self.expanded = false
                 })
        }else{
            let size = self.rootview?.mapview.frame.size;        self.pullUpControllerMoveToVisiblePoint(size!.height * 0.25, animated: true, completion: {
                self.expanded = true
                 })
        }
        
        
        
     
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let size = self.rootview?.mapview.frame.size;         self.pullUpControllerMoveToVisiblePoint(size!.height * 0.50, animated: true, completion: {
        self.expanded = true
         })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searched = true
        searchconcess(search: searchBar.text ?? "")
        
        dismissKeyboard()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calledroad = concess[indexPath.row]
        let cs = CharacterSet.init(charactersIn: "-")
        calledroad.telefone = calledroad.telefone.trimmingCharacters(in: cs)
        let sosdb: Sosdb =  Sosdb(data: calledroad,rootview: self.rootview!)
        sosdb.call()
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
    }
    
    func searchconcess(search: String){
        if(search.isEmpty){
            
            return
        }
        let query = Database.database().reference()
        query.keepSynced(true)
        self.noresults.text = ""
        print("searching for " + search)
        
        
        
        progressview.startAnimating()
        self.concess.removeAll()
        self.concesstable.reloadData()
        
        self.ref.child("rodovias")
            .observe(.childAdded, with:  { (snapshot) in
    

                if(snapshot.exists()){
                    let value = snapshot.value as? NSDictionary
                                           let r = value?["rodovia"] as! String
                                           let  c = value?["concessionaria"] as! String
                                           let t = value?["telefone"] as! String
                    if r.contains(search) || c.contains(search) {
                          print(snapshot.value as Any)
                          let road = Road(rodovia: r, concessionaria: c, telefone: t)
                          self.concess.append(road)
                        self.founded = true

                    }else{
                       
                    }
                    

                }
               self.searchbar.placeholder = search
                self.showview()

                
                
            })  { (error) in
                print("Firebase error -> " + error.localizedDescription)
                self.noresults.text = "Nenhum resultado encontrado para " + search
                //self.rootview?
                self.showview()
                
        }
    }
    
    
    
    
    
    
    
   
    
    func showview(){
        print("concessionarias")
        self.scrollindicator.backgroundColor = UIColor.systemRed
        self.concesstable.reloadData()
        print(String(self.concess.count) + " concessionarias encontradas")
        dump(self.concess)
      
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { //
                if(self.concess.count == 0){
                    self.noconcess()
                    self.progressview.stopAnimating()
                    self.noresults.text = "Nenhum resultado encontrado"
                }else{
                    self.progressview.stopAnimating()
                    if self.searched{
                        self.rootview?.movemap(address: self.searchbar!.text!)
                    }
                    
                    self.noresults.text = String(self.concess.count) + " resultados encontrados"
                    
                    
                }
 
            }
        self.slideup()
        
        

    }
    
    
    func noconcess(){
        
        if(isaroad(endereco: searchbar.text!)){
            var needtosuggest = false
                   self.ref.child("suggestion")
                   .queryOrdered(byChild: "rodovia")
                       .observe(.childAdded, with: {(snapshot) in
                           let value = snapshot.value as? NSDictionary
                           let r = value?["rodovia"] as! String
                           let checked = value?["checked"] as? Bool
                           if(!r.contains(self.searchbar.text!) || !(checked == false)){
                               needtosuggest = true
                           }
                       })
                       { (Error) in
                           print("Firebase error " + Error.localizedDescription)
                   }
                   
                   
                   DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //
                   if(needtosuggest){
                       self.notfoundalert()
                   }else{
                       self.noresults.text = "Esse endereço não possui concessionárias"
                   }
                   
                   
                   }
        }else{
            
            
            self.noresults.text = "Esse endereço não possui concessionárias"
            if(warned){
                return
            }
            let alert = UIAlertController(title: "Atenção", message: "Ruas e avenidas não possuem concessionárias" , preferredStyle: .alert)
            let ok = UIAlertAction(title:"Ok", style: .cancel){
                UIAlertAction in
                self.warned = true
            }
            alert.addAction(ok)
            self.present(alert,animated: true,completion: {
                self.warned = true
            })
        }
        self.founded = false
        
       
        
    }
    
    func notfoundalert(){
        
        let message = "Não encontramos nenhuma concessionária neste endereço(" + searchbar.text! + ")"
        let optionMenu = UIAlertController(title: "Atenção!", message: message , preferredStyle: .alert)
        let suggestaction = UIAlertAction(title: "Sugerir endereço",style: .default){UIAlertAction in
            self.SendSuggestion(endereco: self.searchbar.text!)
            
        }
        optionMenu.addAction(suggestaction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .destructive){
            UIAlertAction in
            self.closed = true
        }
        
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    func SendSuggestion(endereco:String){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        if(!endereco.contains("rodovia") || (!endereco.contains("Rodovia"))){
            let alert = UIAlertController(title: "Atenção", message: "Ruas e avenidas não possuem concessionárias" , preferredStyle: .alert)
            let ok = UIAlertAction(title:"Ok", style: .cancel){
                UIAlertAction in
                self.closed = true
            }
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
        }else{
        ref.child("suggestion").childByAutoId().setValue(["rodovia": endereco,"data":formatter.string(from: date)], withCompletionBlock: {_,_ in
                let alert = UIAlertController(title: "Obrigado", message: "Sua sugestão foi enviada com sucesso!" , preferredStyle: .alert)
                           let ok = UIAlertAction(title:"Ok", style: .cancel){
                               UIAlertAction in
                               self.closed = true
                           }
                alert.addAction(ok)
                self.present(alert,animated: true)
            })
               
            self.closed = true
        }
    
    }
}

