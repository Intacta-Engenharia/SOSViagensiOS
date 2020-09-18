//
//  AlertView.swift
//  SOSVIagens
//
//  Created by Intacta Engenharia on 07/11/19.
//  Copyright © 2019 Intacta Engenharia. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseDatabase

class AlertView: UIView {
    
    static let instance = AlertView()
    
    var road: Road? = nil
    var viewcontroller: UIViewController? = nil
    @IBOutlet var parentview: UIView!
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var infolbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("CommentView", owner: self, options: nil)
        commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func commonInit(){
        parentview.layer.cornerRadius = 10
        parentview.frame = CGRect(x: 0 ,y: 0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
        parentview.autoresizingMask = [.flexibleHeight,.flexibleWidth]
      
    }
    
    func showalert(road: Road, viewcontroller: UIViewController){
        self.road = road
        self.viewcontroller = viewcontroller
        self.infolbl.text = "Avalie sua experiência com a " + road.concessionaria
        
        UIApplication.shared.keyWindow?.addSubview(self.parentview)
    }
    
    
    @IBAction func SendComments(_ sender: Any) {
           if(road == nil){
                let alert = UIAlertController(title: "Erro", message: "Não conseguimos recuperar a concessionária que você ligou!", preferredStyle: .alert)
                      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                      
            self.viewcontroller?.present(alert, animated: true)
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
           
           ref.child("comments").childByAutoId().setValue(["comment": comment.comment,"concessionaria": comment.concess,"rodovia":comment.road, "data": formatter.string(from: date),"opinion": Double(comment.rating).rounded(),"user": ""])
           let alert = UIAlertController(title: "Obrigado", message: "O comentário foi enviado com sucesso!", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
           
        self.viewcontroller?.present(alert, animated: true)
      
           
       }
    
}

