//
//  CommentViewController.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 06/05/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import FirebaseUI
import GoogleSignIn
import PullUpController

class CommentViewController: PullUpController,UITextViewDelegate {
   
 
     var rootview: MapSceneViewController? = nil
    
    override var pullUpControllerPreferredSize: CGSize {
            let screenSize: CGRect = UIScreen.main.bounds
        return screenSize.size
           

       }
    
    
    
  
   
    func showviews(){
        self.rating?.alpha = 1
        self.comments?.alpha = 1
        self.infolbl?.alpha = 1
    }
    func hideviews(){
            self.pullUpControllerMoveToVisiblePoint(0, animated: true, completion: {
                self.rating.alpha = 0
                self.comments.alpha = 0
                self.infolbl.alpha = 0
            })
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.hideviews()
        
    }
    
    func checkUser(){
     }
    
    @IBOutlet weak var rating: CosmosView!
    var road:Road?
   
    @IBAction func savebtn(_ sender: Any) {
        
        if(road == nil){
             let alert = UIAlertController(title: "Erro", message: "Não conseguimos recuperar a concessionária que você ligou!", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                   
                   self.present(alert, animated: true)
            return
        }
        var ref: DatabaseReference!
        var comnt = ""
        ref = Database.database().reference()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        if comments.text !=  "Conte como foi seu atendimento" {
           comnt = comments.text
        }
        let comment:Comment = Comment(road: self.road!.rodovia, comment: comnt, concess: self.road!.concessionaria, user: "", rating: rating.rating)
        
        ref.child("comments").childByAutoId().setValue(["comment": comment.comment,"concessionaria": comment.concess,"rodovia":comment.road, "data": formatter.string(from: date),"opinion": Double(comment.rating).rounded(),"user": ""],withCompletionBlock: {_,_ in
            let alert = UIAlertController(title: "Obrigado", message: "O comentário foi enviado com sucesso!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {UIAlertAction in
            
                self.hideviews()
            }))
            self.present(alert, animated: true)
        })
        
        
    }
    
    @IBOutlet weak var infolbl: UILabel!
    
    @IBOutlet weak var comments: UITextView!
    
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(comments.text == "Conte como foi seu atendimento"){
            comments.text = ""
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if comments.text == ""{
            comments.text = "Conte como foi seu atendimento"
            comments.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            comments.resignFirstResponder()
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comments.delegate = self
         infolbl.text = "Conte como foi sua experiência com a " + self.road!.concessionaria + " em " + self.road!.rodovia
        
        //FirebaseApp.configure()
 
        // You need to adopt a FUIAuthDelegate protocol to receive callback
 
        
        }
        // Do any additional setup after loading the view.
    }
    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


