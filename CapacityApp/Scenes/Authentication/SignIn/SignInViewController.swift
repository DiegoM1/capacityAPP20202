//
//  ViewController.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 10/5/20.
//

import UIKit
import FirebaseAuth
import CoreLocation

class SignInViewController: UIViewController {

    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUp.layer.masksToBounds = true
        signUp.layer.cornerRadius = 25
        signUp.setTitle( "Sign Up",for: .normal)
        logIn.layer.masksToBounds = true
        logIn.layer.cornerRadius = 25
        logIn.setTitle( "Log In",for: .normal)
        username.layer.shadowColor = UIColor.black.cgColor
        username.layer.shadowOffset = CGSize(width: 1, height: 2)
        username.layer.shadowOpacity = 0.4
        username.layer.shadowRadius = 3.0
        username.backgroundColor = .systemBackground
        username.layer.masksToBounds = false
        assignbackground()
        password.layer.shadowColor = UIColor.black.cgColor
        password.layer.shadowOffset = CGSize(width: 1, height: 2)
        password.layer.shadowOpacity = 0.4
        password.layer.shadowRadius = 3.0
        password.backgroundColor = .systemBackground
        password.layer.masksToBounds = false
        logIn.addTarget(self, action: #selector(auth), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    
        func assignbackground(){
                let background = UIImage(named: "login2.png")

                var imageView : UIImageView!
                imageView = UIImageView(frame: view.bounds)
            imageView.contentMode =  UIView.ContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = background
                imageView.center = view.center
                view.addSubview(imageView)
                self.view.sendSubviewToBack(imageView)
            }
    
    
    @objc func auth(){
        guard let username = username.text, let psw = password.text else { return }
    
        Auth.auth().signIn(withEmail: username, password: psw) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error == nil {
                guard let vc = self?.storyboard!.instantiateViewController(identifier: "mapView") else { return }
                let vcNavController = UINavigationController(rootViewController: vc)
                vcNavController.modalPresentationStyle = .fullScreen
                
                strongSelf.present(vcNavController, animated: true, completion: nil)
                
            } else {
                
                let ac = UIAlertController(title: "Error",message: error?.localizedDescription, preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(ac, animated: true, completion: nil)
                
                print(error!)
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signup", let vc = segue.destination as? CreateAccountViewController {
            
            vc.model = CreateAccountModel(view: vc)
            
        }
    }
}

