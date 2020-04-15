//
//  GalleryViewController.swift
//  Virtual Tourist
//
//  Created by Abdalfattah Altaeb on 4/14/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class GalleryViewController:  UIViewController,NSFetchedResultsControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {

    //MARK:- Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var label: UILabel!

    //MARK:- Properties
    var dataController: DataController!
    var pin: Pin!
    var locationImages = [Photo]()
    var placeholders = [UIImage]()

    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        mapSetup()

        collectionSetup()

        label.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collection.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if(pin.photos?.count == 0){
            downloadPhotos()
        }else{
            fetchPhotos()
        }
    }

    //MARK:- Actions
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func newAlbum(_ sender: Any) {
        for photo in locationImages{
            let index = locationImages.firstIndex(of: photo)!
            locationImages.remove(at: index)
            placeholders.remove(at:  index)
            collection.reloadData()
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }

        setupPlaceholders()
        downloadPhotos()

    }

    //MARK:- Functions

    //MARK:- downloadPhotos
    private func downloadPhotos(){
        FlickrClient.sharedInstance().getPagesFromFlickrBySearch(latitude: Double(self.pin!.latitude), longitude: Double(self.pin!.longitude),pin: pin,dataController: self.dataController){ (success,error) in
            DispatchQueue.main.async {
                if success{
                    self.fetchPhotos()
                }else{
                    self.placeholders.removeAll()
                    self.label.isHidden = false
                    self.collection.reloadData()
                }
            }
        }
    }

    //MARK:- fetchPhotos
    private func fetchPhotos(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.predicate = predicate

        if let result = try? self.dataController.viewContext.fetch(fetchRequest){
            self.placeholders.removeAll()
            self.locationImages.removeAll()
            for photo in result {
                self.placeholders.append(UIImage(data: photo.image!)!)
                self.locationImages.append(photo)
            }

            if(placeholders.isEmpty){
                self.placeholders.removeAll()
                self.label.isHidden = false
                self.collection.reloadData()
            }
            self.collection.reloadData()
        }
    }


}

//MARK:- extension for CollectionView Functions
extension GalleryViewController{
    //MARK:- numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeholders.count

    }

    //MARK:- cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! LocationCollectionViewCell
        let photo = placeholders[(indexPath as NSIndexPath).row]
        cell.locationImage.image = photo
        return cell

    }

    //MARK:- didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = locationImages[(indexPath as NSIndexPath).row]
        locationImages.remove(at: (indexPath as NSIndexPath).row)
        placeholders.remove(at: (indexPath as NSIndexPath).row)
        self.collection.reloadData()
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
    }

    //MARK:- collectionSetup
    func collectionSetup(){
        let space:CGFloat = 3.0
        let dimensionWidth = (view.frame.size.width - (2 * space)) / 3.0
        let dimensionHeight = (view.frame.size.height - (2 * space)) / 2.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)

        setupPlaceholders()

    }

    //MARK:- setup placeholders
    func setupPlaceholders(){
        for _ in 0...14{
            placeholders.append(UIImage(named: "placeHolderImage")!)
        }

        collection.reloadData()
    }
}

//MARK:- extension for MapViewFunctions
extension GalleryViewController{

    //MARK:- viewFor
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    //MARK:- mapFOcus
    func mapSetup(){
        // create pin coordinates
        let latitude  = CLLocationDegrees(pin.latitude)
        let longitude = CLLocationDegrees(pin.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // create the pin's annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        // add pin to map
        self.map.addAnnotation(annotation)

        // Zoom in the map
        let span = MKCoordinateSpan(latitudeDelta:0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        map.setRegion(region, animated: true)
    }
}
