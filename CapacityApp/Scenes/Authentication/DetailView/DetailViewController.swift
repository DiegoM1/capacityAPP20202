//
//  DetailViewController.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 11/3/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class DetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var inButton: UIButton!
    @IBOutlet weak var outButton: UIButton!
    @IBOutlet weak var peopleNumber: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var restaurant : Restaurant?
    var ref: DatabaseReference! = Database.database().reference()
    var pickerView: UIPickerView!
    var pickerData = [1,2,3,4,5,6,7,8,9]
    
    override func viewDidLoad() {
        peopleNumber.text = ""
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        super.viewDidLoad()
        pickerView = UIPickerView(frame: CGRect(x: 10, y: 50, width: 250, height: 150))
        pickerView.delegate = self
        pickerView.dataSource = self
        title = "\(restaurant!.title)"
        address.text = restaurant?.address.components(separatedBy: ",").first
        ratingLabel.text = "\(restaurant!.rating)" + "⭐"
        
        setPeopleNumber() {
            (text) in
            self.peopleNumber.text = text
            print("texto añadido")
            self.indicator.stopAnimating()
            self.verifyCheckin()
        }
        
        
    }
    
   
    func setPeopleNumber (_ completionHandler: @escaping (String) -> ()) {
        
        self.ref.child("places").child(restaurant!.title).observe(.value, with: { ( snapshot ) in
            
            guard let value = snapshot.value as? Int else { return }
            completionHandler(String(value))
        })
        
 
    }
    
    func verifyCheckin() {
        let user = Auth.auth().currentUser
        self.ref.child("Checkings").observeSingleEvent(of: .value, with: {
            ( response ) in
            print(response)
            let valueUser = response.value as? NSDictionary
            guard let value = valueUser?[user!.uid] as? NSDictionary else {
                self.outButton.isEnabled = false
                if self.outButton.state == .disabled {
                    self.outButton.setTitleColor(.systemBlue , for: .normal)
                }
                return }
            
            if value["place"] as? String == self.restaurant?.title {
                self.inButton.isEnabled = false
                if self.outButton.state == .normal {
                    self.outButton.setTitleColor(.systemRed, for: .normal)
                }
                return
            } else {
            let ac = UIAlertController(title: "Porfavor marque su salida", message: "\(value["place"]!)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default) { _ in self.navigationController?.popToRootViewController(animated: true)
                    
                })
            self.present(ac, animated: true, completion: nil)
            self.inButton.isEnabled = false
                
            }
        })
    }
    
    func setRestaurantData (_ completionHandler: @escaping (NSDictionary) -> ()) {
        var value = 0
        
        self.ref.child("annotations").child(restaurant!.title).observe(.value, with: { ( snapshot ) in
            guard let valueRestaurant = snapshot.value as? NSDictionary else { return }
            completionHandler(valueRestaurant)
        })
        
 
    }
    @IBAction func inAction(_ sender: Any) {
        
        
            showAlert()
        
        
        
    }
    
    func showAlert() {
            let ac = UIAlertController(title: "Nº de personas", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            ac.view.addSubview(pickerView)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let pickerValue = self.pickerData[self.pickerView.selectedRow(inComponent: 0)]
                self.ref.child("places").child(self.restaurant!.title).observeSingleEvent(of: .value, with: { ( snapshot ) in
                  var newValue = snapshot.value as! Int
                    newValue += pickerValue
                    self.ref.child("places").child(self.restaurant!.title).setValue(newValue)
                    guard let user = Auth.auth().currentUser else { return }
                    self.ref.child("Checkings").child(user.uid).observeSingleEvent(of: .value, with: {
                        ( data ) in
                        guard  let userValue = snapshot.value as? Int else {
                            self.ref.child("Checkings").child(user.uid).setValue(["place": self.restaurant!.title , "Amount": pickerValue])
                            return
                        }
                        self.ref.child("Checkings").child(user.uid).setValue(["place": self.restaurant!.title , "Amount": userValue + pickerValue])
                        
                    })
                } )
                print("Picker value: \(pickerValue) was selected")
                self.inButton.isEnabled = false
                self.outButton.isEnabled = true
                if self.outButton.state == .normal {
                    self.outButton.setTitleColor(.systemRed, for: .normal)
                }
                
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true)
        }

    @IBAction func outAction(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        var currentValue = 0
        self.ref.child("places").child(self.restaurant!.title).observeSingleEvent(of: .value, with: { ( snapshot ) in
            currentValue = snapshot.value as! Int
        })
        self.ref.child("Checkings").observeSingleEvent(of: .value, with: {
           ( response ) in
            print(response)
            let valueUser = response.value as? NSDictionary
            guard let value = valueUser?[user.uid] as? NSDictionary else { return }
            let userValue = value["Amount"] as! Int
                    let newValue = currentValue - userValue
                       self.ref.child("Checkings").child(user.uid).removeValue()
                       self.ref.child("places").child(self.restaurant!.title).setValue(newValue)
        } )
        inButton.isEnabled = true
            
    }
    
    deinit {
        print("dealloc DetailViewController")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
}
