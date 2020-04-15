# Virtual Tourist [![Travis CI](https://travis-ci.org/emreozdil/virtual_tourist.svg?branch=master)](https://travis-ci.org/emreozdil/virtual_tourist/builds) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)]
iOS Developer Nanodegree Project

The Virtual Tourist is result of **iOS Persistence and Core Data** lesson of **Udacity's iOS Developer Nanodegree** course.

An application that let you travel virtually to any place in the world with the help of the Flickr API. The app allows users to drop pins on a map, as if they were stops on a tour. The idea is that you drop a pin to any location in the map and the app will let you view images from each location. 

The app will start downloading the appropriate photos from Flickr related with the location and will be displayed in a collection view as soon as you drop the pin on the Map, if you want to see more pictures you can use the "New Collection" button. The app will remember the places where you dropped a pin on a previous trip. Users will also be able to move pins to download new pictures and remove pins if they need them anymore.

The goal of this Application is to work deeper with Core Data exploring the Data stack model, how to architect a Core Data Stack

- [Read the project specification.](https://docs.google.com/document/d/1j-UIi1jJGuNWKoEjEk09wwYf4ebefnwcVrUYbiHh1MI/pub?embedded=true)

## Implementation

The Application has two View Controller Scenes:

- **MapController** - When the Application first starts it will open to the Map View. Users will be able to zoom and scroll around the map using standard pinch and drag gestures. The center of the Map and the zoom level is persistent i.e If the application is terminated, and whenever the application is Re-Opened the Map's Reegion and center will be the same as it was before the application was termined. Tapping and Holding the Map Drops a New Pin. Users can place any number of Pins on the Map. When a Pin is Tapped, the application is navigated to the Photo Album Collection View associated with the Pin.

- **CollectionController** - If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin. If no images are found a “No Images” label will be displayed. If there are images, then they will be displayed in a collection view. While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled. The app should determine how many images are available for the pin location, and display a placeholder image for each.

  Once the images have all been downloaded, the app should enable the New Collection button at the bottom of the page. Tapping  this button should empty the photo album and fetch a new set of images. Note that in locations that have a fairly static set of Flickr images, “new” images might overlap with previous collections of images. Users should be able to remove photos from an album by tapping them. Pictures will flow up to fill the space vacated by the removed photo. All changes to the photo album should be automatically made persistent. Tapping the back button should return the user to the Map view.

  If the user selects a pin that already has a photo album then the Photo Album view should display the album and the New Collection button should be enabled.
  
## Requirements

 Xcode 11.0
 Swift 5.0
 
## Screen Shots

 <img src="/ScreenShots/ScreenShot1.png" height="49%" width="49%"> <img src="/ScreenShots/ScreenShot2.png" height="49%" width="49%">
