//
//  MapViewController.swift
//  CapacityApp
//
//  Created by Diego Sebastián Monteagudo Díaz on 11/2/20.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var ref: DatabaseReference! = Database.database().reference()
    
    var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var nearRestaurants = [String]()
    
    lazy var googleClient: GoogleClientRequest = GoogleClient()
    private let searchRadius: Double = 1000
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView = MKMapView(frame: self.view.frame)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        print("indicador primero")
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        guard let location = locationManager.location else { return }
        fetchGoogleData(forLocation: location)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func logout() {
        
        dismiss(animated: true){
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        self.mapView!.setRegion(region, animated: true)
        self.mapView!.centerCoordinate = center
        
        self.locationManager.stopUpdatingLocation()
        
        print(location!)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is RestaurantAnnotation else { return nil }
        
        let identifier = "Capital"
        
        var annonationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annonationView == nil {
            annonationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annonationView?.canShowCallout = true
            annonationView?.pinTintColor = .purple
            
            let btn = UIButton(type: .detailDisclosure)
            annonationView?.rightCalloutAccessoryView = btn
        } else {
            annonationView?.annotation = annotation
            
        }
        return annonationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let restaurantAnnotation = view.annotation as? RestaurantAnnotation else { return }
        
        guard  let detailViewController = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailViewController else { return }
        detailViewController.restaurant = restaurantAnnotation.restaurant
        navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension MapViewController {
    
    func fetchGoogleData(forLocation: CLLocation) {
        //guard let location = currentLocation else { return }
        googleClient.getGooglePlacesData(forKeyword: "restaurant", location: forLocation, withinMeters: 2500) { (response) in
            
            self.saveDataInFirebase(places: response.results)
            print("google response")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                print("main queue")
                
                self.mapView!.delegate = self
                self.mapView!.showsUserLocation = true
                self.view.addSubview(self.mapView)
                guard let location = self.locationManager.location else { return }
                let latitude = location.coordinate.latitude
                let longitude = self.locationManager.location!.coordinate.longitude
                let latDelta: CLLocationDegrees = 0.05
                let lonDelta: CLLocationDegrees = 0.05
                let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                let locationCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                let region: MKCoordinateRegion = MKCoordinateRegion(center: locationCoordinate, span: span)
                self.mapView!.setRegion(region, animated: true)
            }
            
        }
    }
    
    func saveNearRestaurants() {
        self.ref.child("annotations").observeSingleEvent(of: .value, with: { ( snapshot ) in
            guard let data = snapshot.value as? NSDictionary else {
                return }
            self.nearRestaurants = data.allKeys as? [String] ?? [""]
            self.addAnnotations(places: self.nearRestaurants)
            print("COnsulto annotations")
        })
    }
    
    func saveDataInFirebase (places: [Place] ) {
        
        var placesNames = [String]()
        let group = DispatchGroup()
        
        places.forEach() { place in
            group.enter()
            self.ref.child("annotations").observeSingleEvent(of: .value, with: { ( snapshot ) in
                placesNames.append(place.name)
                let data = snapshot.value as? NSDictionary
                guard  let _ = data?[place.name] as? NSDictionary else {
                    self.ref.child("annotations").child(place.name).setValue(["latitude": place.geometry.location.latitude, "longitude": place.geometry.location.longitude, "address": place.address, "userRating": place.rating])
                    self.ref.child("places").child(place.name).setValue(0)
                    group.leave()
                    return }
                group.leave()
            })
        }
    
        group.notify(queue: .main) {
            self.saveNearRestaurants()
        }
        
        
    }
    
    
    func addAnnotations(places: [String]) {
        
        var array = [MKAnnotation]()
        for place in places {
            self.ref.child("annotations").observeSingleEvent(of: .value, with: { ( snapshot ) in
                
                let data = snapshot.value as? NSDictionary
                guard  let annotations = data?[place] as? NSDictionary else { return }
                let newAnnotation = RestaurantAnnotation(restaurant: Restaurant(title: place, latitude: annotations["latitude"] as! Double, longitude: annotations["longitude"] as! Double, address: annotations["address"] as! String, rating: annotations["userRating"] as! Double))
                
                array.append(newAnnotation)
                if place == places.last {
                    DispatchQueue.main.async {
                        self.mapView?.showAnnotations(array, animated: true)
                        print("agrego annotations")
                    }
                }
            })
        }
    }
}
