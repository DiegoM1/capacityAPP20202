//
//  CreateAccountViewController.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 10/5/20.
//

import Foundation
import UIKit

class CreateAccountViewController: UIViewController, CreateAccountViewProtocol {
    
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    var model: CreateAccountModel!
    
    override func viewDidLoad() {
        
        userText.placeholder = "Insert your email here"
        
        userText.layer.shadowColor = UIColor.black.cgColor
        userText.layer.shadowOffset = CGSize(width: 1, height: 2)
        userText.layer.shadowOpacity = 0.4
        userText.layer.shadowRadius = 3.0
        userText.backgroundColor = .systemBackground
        userText.layer.masksToBounds = false
        assignbackground()
        passText.placeholder = "Insert your password"
        passText.isSecureTextEntry = true
        passText.layer.shadowColor = UIColor.black.cgColor
        passText.layer.shadowOffset = CGSize(width: 1, height: 2)
        passText.layer.shadowOpacity = 0.4
        passText.layer.shadowRadius = 3.0
        passText.backgroundColor = .systemBackground
        passText.layer.masksToBounds = false
        
        createAccountButton.setTitle("Create account", for: .normal)
        createAccountButton.layer.masksToBounds = true
        createAccountButton.layer.cornerRadius = 25
        createAccountButton.addTarget(self, action: #selector(create), for: .touchUpInside)
        
    }
    
    func assignbackground(){
            let background = UIImage(named: "creacionCuenta.png")

            var imageView : UIImageView!
            imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = background
            imageView.center = view.center
            view.addSubview(imageView)
            self.view.sendSubviewToBack(imageView)
        }
    
    
    @objc func create() {
        guard let text = userText.text, let pass = passText.text else {
            
            return
        }
        model!.createAccount(userField: text, passField: pass)
        
    }
    
    func presentAlert(title: String, message: String) {
        var ac = UIAlertController()
        ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        userText.text = ""
        passText.text = ""
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sign up" {
            model = CreateAccountModel(view: self)
        }
    }
    
}
protocol CreateAccountViewProtocol {
    func presentAlert(title: String, message: String) 
}
