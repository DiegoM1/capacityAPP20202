//
//  Model.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 10/5/20.
//

import Foundation
import FirebaseAuth

struct CreateAccountModel {
    
    let view: CreateAccountViewProtocol
    
     func createAccount(userField emailText:String,passField pass:String){
       
        FirebaseAuth.Auth.auth().createUser(withEmail: emailText, password: pass, completion: { result,error in
            if error == nil {
                view.presentAlert(title: "Creación satisfactoria", message: "Cuenta creada")
            }
            view.presentAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            print("usuario creado")
        })
    }
}


