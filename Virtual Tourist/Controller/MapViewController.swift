//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Abdalfattah Altaeb on 4/13/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    //MARK:- Outlets
    @IBOutlet weak var map: MKMapView!

    //MARK:- Variables
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!

    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        map.addAnnotations(mapAnnotationsFromPins(pins: fetchedResultsController.fetchedObjects!))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

    //MARK:- Actions
    @IBAction func dropPin(_ sender: Any) {
        let gesture = sender as? UILongPressGestureRecognizer

        if(gesture?.state == UILongPressGestureRecognizer.State.began){
            if let location = gesture?.location(in: map){
                let locationCoordinates = self.map.convert(location, toCoordinateFrom: self.map)
                self.addPin(latitude: Float(locationCoordinates.latitude), longitude: Float(locationCoordinates.longitude))

            }
        }
    }

    //MARK:- Functions
    private func mapAnnotationsFromPins(pins:[Pin]) ->[MKPointAnnotation]{
        var annotations = [MKPointAnnotation]()

        for pin in pins{
            annotations.append(annotationFromPin(latitude: pin.latitude, longitude: pin.longitude))
        }

        return annotations
    }

    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    private func annotationFromPin(latitude:Float, longitude:Float) -> MKPointAnnotation{
        // create pin coordinates
        let latitude  = CLLocationDegrees(latitude)
        let longitude = CLLocationDegrees(longitude)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // create the pins's annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        return annotation
    }

    private func addPin(latitude:Float, longitude:Float){
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        try? dataController.viewContext.save()
    }

}

//MARK:- extension for fetchResultController functions
extension MapViewController {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let pin = controller.object(at: newIndexPath!) as! Pin
            map.addAnnotation(annotationFromPin(latitude: pin.latitude, longitude: pin.longitude))
            break
        default:
            break
        }
    }
}

//MARK:- extension for Map functions
extension MapViewController{

    //MARK:- didselect
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let galleryVC = storyboard.instantiateViewController(withIdentifier: "gallery") as! GalleryViewController

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicateLongitude = NSPredicate(format: "longitude = %F", Float((view.annotation?.coordinate.longitude)!))
        let predicateLatitude = NSPredicate(format: "latitude = %F", Float((view.annotation?.coordinate.latitude)!))

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLatitude,predicateLongitude])

        fetchRequest.predicate = compoundPredicate


        if let result = try? dataController.viewContext.fetch(fetchRequest){
            galleryVC.pin = result[0]
            galleryVC.dataController = dataController
            self.present(galleryVC, animated: true)
        }
    }
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
}
