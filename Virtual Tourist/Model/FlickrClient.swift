//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Abdalfattah Altaeb on 4/12/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import Foundation

//MARK:- FlickrClient
class FlickrClient: NSObject{

    //MARK:- Properties
    var session = URLSession.shared

    //MARK:- Initializer
    override init(){
        super.init()
    }

    //MARK:- GET
    func taskForGETMethod(parameters:[String: AnyObject], completionHandlerForGET: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{

        // Build the URL and configure the request
        let request = NSMutableURLRequest(url: udacityURLFromParameters(parameters))

        // Make the request
        return makeRequestWithCompletionHandler(request: request as URLRequest, errorDomain: "taskForGETMethod", comletionHandlerForMakeRequest: completionHandlerForGET)
    }

    //MARK:- Make Request
    private func makeRequestWithCompletionHandler(request: URLRequest, errorDomain: String, comletionHandlerForMakeRequest: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void)-> URLSessionDataTask{
        // Make the request
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in

            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey : error]
                comletionHandlerForMakeRequest(nil, NSError(domain: errorDomain, code: 1, userInfo: userInfo))
            }

            // Guard for error
            guard(error == nil) else{
                sendError("There was an error with your request: Check the internet connection!")
                return
            }

            // Guard for response status
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                sendError(error as! String)
                return
            }

            // Guard for returned data
            guard let data = data  else{
                sendError("No data was returned by the request!")
                return

            }

            // parse and use data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: comletionHandlerForMakeRequest)
        }

        task.resume()

        return task

    }

    //MARK:- Parse JSON
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData:(_ result: AnyObject?, _ error: NSError?) -> Void){

        var parsedResult: AnyObject! = nil

        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            completionHandlerForConvertData(parsedResult,nil)
        }catch{
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }


    }

    //MARK:- URL Creation
    private func udacityURLFromParameters(_ parameters: [String: AnyObject]? = nil) -> URL{
        var components = URLComponents()
        components.scheme = FlickrClient.Flickr.APIScheme
        components.host = FlickrClient.Flickr.APIHost
        components.path = FlickrClient.Flickr.APIPath
        components.queryItems = [URLQueryItem]()

        if let parameters = parameters{
            for (key, value) in parameters{
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!

    }

    //MARK:- Substitute Key for Value in Methods
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String?{
        if method.range(of: "{\(key)}") != nil{
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        }else{
            return nil
        }
    }

    // MARK:- Shared Instance
    class func sharedInstance() -> FlickrClient{
        struct Singelton{
            static var sharedInstance = FlickrClient()
        }
        return Singelton.sharedInstance
    }

}

extension FlickrClient{

    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"

        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }

    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }

    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "a162666efbfa2010362aab2b516d3d54"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }

    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }

    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}
