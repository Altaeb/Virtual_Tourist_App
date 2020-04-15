//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Abdalfattah Altaeb on 4/12/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient{
    func getPagesFromFlickrBySearch(latitude: Double, longitude: Double,pin:Pin, dataController:  DataController,completionHandlerForGetPages: @escaping(_ success: Bool, _ error: String?) -> Void){

        let parameters = [
            FlickrClient.FlickrParameterKeys.Method: FlickrClient.FlickrParameterValues.SearchMethod,
            FlickrClient.FlickrParameterKeys.APIKey: FlickrClient.FlickrParameterValues.APIKey,
            FlickrClient.FlickrParameterKeys.BoundingBox: bboxString(latitude,longitude),
            FlickrClient.FlickrParameterKeys.SafeSearch: FlickrClient.FlickrParameterValues.UseSafeSearch,
            FlickrClient.FlickrParameterKeys.Extras: FlickrClient.FlickrParameterValues.MediumURL,
            FlickrClient.FlickrParameterKeys.Format: FlickrClient.FlickrParameterValues.ResponseFormat,
            FlickrClient.FlickrParameterKeys.NoJSONCallback: FlickrClient.FlickrParameterValues.DisableJSONCallback
        ]

        let _ = taskForGETMethod(parameters: parameters as [String : AnyObject]){ (response, error) in

            if let error = error{
                completionHandlerForGetPages(false,error.userInfo[NSLocalizedDescriptionKey] as? String)
            }else{
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = response?[FlickrClient.FlickrResponseKeys.Status] as? String, stat == FlickrClient.FlickrResponseValues.OKStatus else {
                    completionHandlerForGetPages(false,"Flickr API returned an error. See error code and message in \(response!)")
                    return
                }

                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = response?[FlickrClient.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandlerForGetPages(false,"Cannot find keys '\(FlickrClient.FlickrResponseKeys.Photos)' in \(response!)")
                    return
                }

                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let totalPages = photosDictionary[FlickrClient.FlickrResponseKeys.Pages] as? Int else {
                    completionHandlerForGetPages(false,"Cannot find key '\(FlickrClient.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                    return
                }

                // pick a random page!
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                self.getImagesURL(parameters: parameters as [String : AnyObject], pageNumber: randomPage,pin: pin, dataController: dataController, completionHandlerForGetImages: completionHandlerForGetPages)
            }

        }
    }

    private func getImagesURL(parameters: [String : AnyObject], pageNumber: Int,pin:Pin,dataController: DataController, completionHandlerForGetImages: @escaping(_ success: Bool, _ error: String?) -> Void){

        var newParameters = parameters
        newParameters[FlickrClient.FlickrParameterKeys.Page] = pageNumber as AnyObject
        newParameters[FlickrClient.FlickrParameterKeys.PerPage] = 15 as AnyObject

        let _ = taskForGETMethod(parameters: newParameters){ (response, error) in

            if let error = error{
                completionHandlerForGetImages(false,error.userInfo[NSLocalizedDescriptionKey] as? String)
            }else{
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = response?[FlickrClient.FlickrResponseKeys.Status] as? String, stat == FlickrClient.FlickrResponseValues.OKStatus else {
                    completionHandlerForGetImages(false,"Flickr API returned an error. See error code and message in \(response!)")
                    return
                }

                /* GUARD: Is the "photos" key in our result? */
                guard let photosDictionary = response?[FlickrClient.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandlerForGetImages(false,"Cannot find key '\(FlickrClient.FlickrResponseKeys.Photos)' in \(response!)")
                    return
                }

                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[FlickrClient.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandlerForGetImages(false,"Cannot find key '\(FlickrClient.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }

                if photosArray.count == 0 {
                    completionHandlerForGetImages(false,"No Photos Found. Search Again.")
                } else {
                    for photo in photosArray{
                        if let imageUrlString = photo[FlickrClient.FlickrResponseKeys.MediumURL] as? String{
                            // if an image exists at the url, set the image and title
                            let imageURL = URL(string: imageUrlString)
                            if let imageData = try? Data(contentsOf: imageURL!) {
                                dataController.viewContext.perform {
                                    let photo = Photo(context: dataController.viewContext)

                                    photo.image = imageData
                                    photo.pin = pin

                                    pin.addToPhotos(photo)
                                    do{
                                        try dataController.viewContext.save()
                                    }catch{
                                        fatalError(error.localizedDescription)
                                    }

                                }

                            }
                        }


                    }
                    completionHandlerForGetImages(true,nil)
                }

            }
        }
    }

    private func bboxString(_ latitude: Double, _ longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - FlickrClient.Flickr.SearchBBoxHalfWidth, FlickrClient.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrClient.Flickr.SearchBBoxHalfHeight, FlickrClient.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrClient.Flickr.SearchBBoxHalfWidth, FlickrClient.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrClient.Flickr.SearchBBoxHalfHeight, FlickrClient.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"

    }

}
