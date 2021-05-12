//
//  MapsViewController.swift
//  UsandoMapKit
//
//  Created by Ana Geórgia Gama on 03/05/21.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {

    @IBOutlet weak var mapView         : MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    
    let locationManager: CLLocationManager       = CLLocationManager()
    var lastLocation   : CLLocationCoordinate2D? = nil
    var selectedAddress: Address?                = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate         = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.showsUserLocation = true
        
        locationManager.startUpdatingLocation()
        
        if let address = selectedAddress {
            showRoute(address)
        }
    }
    
    @IBAction func tappedShowAddress(_ sender: Any) {
        getPossibleAddressesFromText()
    }
    
    private func getPossibleAddressesFromText() {
        var addresses: [Address] = []
        CLGeocoder().geocodeAddressString(addressTextField.text!) { (placemarks, error) in
            if error == nil {
                for placemark in placemarks! {
                    addresses.append(self.convertToAddress(placemark: placemark))
                }
                
                self.showAddressTable(addresses: addresses)
            }
            else {
                let controller = UIAlertController(title: "Error", message: "Problem trying to fetch address from the text", preferredStyle: UIAlertController.Style.alert)
                self.present(controller, animated: true)
            }
        }
    }
    
    private func convertToAddress(placemark: CLPlacemark) -> Address {
        return Address(name: placemark.postalAddress!.street, placemark: placemark, postalAddress: placemark.postalAddress!)
    }
    
    private func showAddressTable(addresses: [Address]) {
        let addressesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddressesTableViewController") as! AddressesTableViewController
        
        addressesVC.addresses       = addresses
        addressesVC.selectedAddress = { address in
            self.selectedAddress = address
        }
        
        self.navigationController?.pushViewController(addressesVC, animated: true)
    }
    
    private func showRoute(_ address: Address) {
        let destinationAnnotation        = MKPointAnnotation()
        destinationAnnotation.coordinate = address.placemark.location!.coordinate
        destinationAnnotation.title      = address.name
       
        self.mapView.addAnnotation(destinationAnnotation)
        
        let request           = MKDirections.Request()
        request.source        = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation!))
        request.destination   = MKMapItem(placemark: MKPlacemark(placemark: address.placemark))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
}


extension MapsViewController: CLLocationManagerDelegate {
    
    // [CLLocation] = array de locations - in this case we only need the last one but some cases you might need more than one
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location             = locations.last
        self.lastLocation        = location?.coordinate
        mapView.centerCoordinate = location!.coordinate
        
        let region = mapView.regionThatFits(MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0))
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension MapsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer         = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.lineWidth   = 5.0
        
        return renderer
    }
}
