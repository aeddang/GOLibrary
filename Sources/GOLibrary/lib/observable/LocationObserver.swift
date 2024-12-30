//
//  LocationObserver.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/07.
//
import SwiftUI
import Foundation
import CoreLocation



public struct LocationAddress {
    var street:String? = nil
    var city:String? = nil
    var state:String? = nil
    var zipCode :String? = nil
    var country :String? = nil
    public var info:String {
        get {
            var s:String = self.country ?? ""
            s = s + (s.isEmpty ? "" : ", ") + (self.state ?? "")
            if self.state != self.city {
                s = s + (s.isEmpty ? "" : ", ") + (self.city ?? "")
            }
            s = s + (s.isEmpty ? "" : ", ") + (self.street ?? "")
            return s
        }
    }
}


open class LocationObserver: NSObject, ObservableObject, CLLocationManagerDelegate {
    public enum Event {
        case updateAuthorization(CLAuthorizationStatus), updateLocation(CLLocation)
    }
    private let  locationManager = CLLocationManager()
    private(set) var isSearch:Bool = false
    private(set) var requestId:String? = nil
    private(set) var finalLocation:CLLocation? = nil
    @Published public private(set)var event: Event? = nil
    {
        didSet{
            if self.event == nil { return }
            self.event = nil
        }
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    deinit {
        self.locationManager.delegate = nil
        if self.isSearch {
            locationManager.stopUpdatingLocation()
            self.isSearch = false
        }
    }
    
    public var status:CLAuthorizationStatus {
        get{
            if #available(iOS 14.0, *){
                return self.locationManager.authorizationStatus
            } else {
                return CLLocationManager.authorizationStatus()
            }
        }
    }
    
    public func requestLocationAccess() -> Bool {
        let status = self.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            return true
        } else if status == .denied {
            self.alertToEncourageLocationAccess { }
            return false
        } else {
            self.requestWhenInUseAuthorization()
            return false
        }
    }
    
    public func requestWhenInUseAuthorization(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    open func alertToEncourageLocationAccess(cancel: @escaping () -> Void)
    {
        /*
        let locationUnavailableAlertController = UIAlertController (
            title: String.alert.requestAccessLocation,
            message: String.alert.requestAccessLocationText,
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: String.app.setting, style: .destructive) { (_) -> Void in
            AppUtil.goAppSettings()
        }
        let cancelAction = UIAlertAction(title: String.app.cancel, style: .default) { (_) -> Void in
            cancel()
        }
        locationUnavailableAlertController .addAction(settingsAction)
        locationUnavailableAlertController .addAction(cancelAction)
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        DispatchQueue.main.async {
            window?.windows.first?.rootViewController?.present(
                locationUnavailableAlertController , animated: true, completion: {
                
            })
        }
        */
    }
    /*
    public let kCLLocationAccuracyBestForNavigation: CLLocationAccuracy
    public let kCLLocationAccuracyBest: CLLocationAccuracy
    public let kCLLocationAccuracyNearestTenMeters: CLLocationAccuracy
    public let kCLLocationAccuracyHundredMeters: CLLocationAccuracy
    public let kCLLocationAccuracyKilometer: CLLocationAccuracy
    public let kCLLocationAccuracyThreeKilometers: CLLocationAccuracy
    */
    public func requestMe(_ isStart:Bool, id:String? = nil, desiredAccuracy:CLLocationAccuracy? = nil, allowsBackground:Bool = false ){
        if isStart {
            if self.isSearch {
                if let loc = self.finalLocation {
                    self.event = .updateLocation(loc)
                }
                return
                
            }
            self.isSearch = true
            if let id = id { self.requestId = id }
           
            if let desiredAccuracy = desiredAccuracy {
                locationManager.desiredAccuracy = desiredAccuracy
            }
            locationManager.distanceFilter = 1
            locationManager.activityType = .fitness
            locationManager.allowsBackgroundLocationUpdates = allowsBackground
            locationManager.showsBackgroundLocationIndicator = allowsBackground
            locationManager.startUpdatingLocation()
        } else {
            if !self.isSearch { return }
            if let id = id , let prev = self.requestId{
                if id != prev { return }
            }
            self.isSearch = false
            self.requestId = nil
            locationManager.stopUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.event = .updateAuthorization(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.finalLocation = location
        self.event = .updateLocation(location)
    }
    
    func convertLocationToAddress(location:CLLocation, com:@escaping (LocationAddress) -> Void) {
        self.convertLatLongToAddress(latitude:location.coordinate.latitude ,longitude:location.coordinate.longitude , com:com)
    }
    
    open func convertLatLongToAddress(latitude:Double,longitude:Double, com:@escaping (LocationAddress) -> Void)  {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var address = LocationAddress()
            
            if let placeMark = placemarks?[0] {
                // Street address
                address.street = placeMark.thoroughfare
                // City
                address.city = placeMark.locality
                // State
                address.state = placeMark.administrativeArea
                // Zip code
                address.zipCode = placeMark.postalCode
                // Country
                address.country = placeMark.country
                com(address)
            } else {
                com(address)
            }
        })
        
    }
    
    
}

