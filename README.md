# Marvel Comic Lookup

This is a Marvel Comic lookup mobile application which displays information from the Marvel API that is associated with the Comic ID that the user inputs into the application search bar.


## Table of Contents
* [Application Description](#Application-Description)
* [Technologies & Frameworks](#Technologies-&-Frameworks)
* [Developer Keys](#Developer-Keys)
* [Setup](#Setup)
* [Testing](#Testing)
* [How to Use](#How-to-Use)
* [Project Status](#Project-Status)
* [Sources](#Sources)


## Application Description

Every comic on the Marvel website has a correlating Comic ID that can be used to lookup the comic through the Marvel API.

This application prompts users to enter a comic ID into the search bar. The app uses this user inputted Comic ID to make an API request to the Marvel API, which returns data about the comic associated with the Comic ID. The resulting data is then parsed through JSON. The app then displays the comic book title, cover image, description (if available), and an attribution link associated with the comic.

The app gets the data from the Marvel API using asynchronous tasking. Later in execution, the app uses a url to get the cover image for the comic, once again using asynchronous tasking. In these two cases, asynchronous tasking is used so the execution of the rest of the application is not slowed down.

The code that displays the data (title, cover image, description, and attribution url) to the UI for the user to view cannot execute until the two asynchronous tasks (getting and processing data, and using a url to get the cover image) are completed. As a result, the code that displays the data to the UI is inside a Dispatch Queue closure and is associated with the main thread of the program. This code has to wait for the data to become available before it can display the data to the UI.

When each asynchronous task starts, the main queue is notified that an asynchronous task has started and it should wait for completion. Once the asynchronous task ends, the main queue is notified that the asynchronous task has completed, and the main thread can continue its execution.

If an invalid Comic ID is inputted or if the user forgets to input a Comic ID, the app  notifies the user and asks them to try again. If there is an error getting data from the Marvel API, the user is notified and told to check their internet connection or to try again later (perhaps there is a server side issue and the app cannot get data until the issue has been resolved).


## Technologies & Frameworks

### Built With
* Xcode 12.4
* Swift 5

### Frameworks
* Marvel Developer API - **developer.marvel.com**
* Foundation
* UIKit

### Libraries
* Swift Standard Library
* Object Library
* Image Library (for app icon images and image on launch screen)

### UI
* Main.storyboard (For main interface user interface)
* LaunchScreen.storyboard (For launch screen)
* Icon Resize (External application that resizes app icon images)

### Testing
* XCTest

### Deployment Target
* iOS 14.4
* iPhone only
* Portrait orientation only


## Developer Keys

### How do developer keys work?
To use the Marvel API, you need a set of developer keys (public key and private key), which are used in the URL requests to the Marvel API. 

To add your developer keys to this project, you will have to make a change to the code in ViewController.swift. In this file, the constant baseURL contains the Marvel API's base endpoint. The constant urlKeys contains the apikeys, a timestamp, and a hash. These two constants (baseURL and urlKeys) are combined with the comic ID input taken from the user to create the url that will be used to make the request to the Marvel API. 

 The Marvel API request must contain the following:
* apikey - your public developer key
* ts - a timestamp (or other long string which can change on a request by request basis)
* hash - an md5 digest of the ts parameter, your private key, and your public key

### Example Scenario
* apikey - cake
* ts - 1
* private key - banana
* hash - md5 hash of 1bananacake (ts + private key + public key)

* NOTE: This app does not use an internal encryption to encrypt the hash with md5. As a result, the timestamp does not change from request to request, it stays the same. You must use an external program to get the hash, and copy the hash value into the ViewController file.*

### How to add your developer keys
To add your developer keys into this program, download the project and open the ViewController.swift file. Locate the urlKeys constant at the top of the ViewController file, and make the following changes.
* **ts=your_time_stamp**
* **apikey=your_public_key**
* **hash=your_hash**

When you are done, the urlKeys constant should look like the following:
* **"?ts=your_time_stamp&apikey=your_public_key&hash=your_hash"**

Where:
* **your_time_stamp** - a timestamp or string that you choose, this string will not change from request to request in this particular program
* **your_public_key** - your public developer key, you can find this in your account on the Marvel Developer website
* **your_hash** - the md5 hash, you must get this hash from an external program since this particular program does not use an internal encryption.


## Setup

### To run this project with Xcode Simulator
1. Download this project to your computer.
2. Open this project with Xcode.
3. Choose the target in the Xcode Toolbar - Select an iPhone under iOS Simulators
4. Run project

### To run this project with on external device
1. Download this project to your computer.
2. Open this project with Xcode.
3. Connect your external device to the computer with a USB cable.
* **NOTE: Before running an Xcode project on an external device that is connected to the computer, you must complete the following steps if this setup has not been completed prior to this**
4. Add your Apple ID in Accounts and Preferences.
5. In the "Navigators" Pane, select the topmost file (it is a blue icon, followed by the name of the application).
6. Choose your application under "Targets" and then select "Signing and Capabilities" in the Project Editor.
7. Assign the project to a team.
* **NOTE: If you are registered with the Apple Developer Program, register your external device before running the application**
8. Select "Signing and Capabilities" under "Target" in theAssign the project to a team on the Signing and Capabilities tab in Project editor
9. Create a Provisioning Profile by logging into Xcode if you don't already have one (Xcode -> Preferences -> Accounts)
* **NOTE: If you are registered with the Apple Developer Program, you will need a Development Certificate before creating the Provisioning Profile**
10. Assign provisioning profile to the project under "Signing and Capabilities"
11. Choose the target in the Xcode Toolbar - Select your external device under iOS Simulators
12. Run project


## Testing

### There are 4 Unit Tests included in the project - All tests pass when run
1. testValidID - testing app with valid comic ID for a comic that has a description
* *Running this test manually will result in: app displaying comic title, cover image, description, and attribution url associated with the given comic ID*
2. testNoDescription - testing app with valid comic ID for a comic that does not have a description
* *Running this test manually will result in: app displaying comic title, cover image and attribution url associated with the given comic. App will display message "Description not available for this comic" instead of the comic description.*
3. testInvalidID - testing app with invalid comic ID
* *Running this test manually will result in: app displaying alert with a message "You provided an invalid comic ID. Please try again." Nothing will be displayed on screen.*
4. testNoID - testing app with no comic ID inputted by user
* *Running this test manually will result in: app displaying alert with message "You forgot to provide a comic ID. Please try again." Nothing will be displayed on screen.*

### There are 3 UI Tests included in the project - All tests pass when run
1. testValidID - testing app with valid comic ID.
* *Test Behavior: App opens, tap on search bar, valid Comic ID inputted to the search bar, search button pressed, comic information displays on screen, scroll down the page, scroll up the page - end of test*
2. testInvalidID - testing app with invalid comic ID
* *Test Behavior: App opens, tap on search bar, invalid Comic ID inputted to the search bar, search button pressed, alert displayed to user with message "You provided an invalid comic ID. Please try again," no other display on screen, alert dismissed - end of test*
3. testNoID - testing app with no comic ID inputted by user
* *Test Behavior: App opens, tap on search bar, invalid Comic ID inputted to the search bar, search button pressed, alert displayed to user with message "You forgot to provide a comic ID. Please try again," no other display on screen, alert dismissed - end of test*

## How to Use

1. Open the application.
2. Tap on the search bar.
3. Input a Comic ID.
4. Tap the "Search" button.
5. The information associated with the Comic ID that was inputted by the user will displayed to the screen.
6. If the information does not all fit on the screen, then screen is vertically scrollable.
7. If there is a mistake in the Comic ID that is inputted by the user, or if there is an internet connection issue, or the application is not able to successfully get data from the Marvel API, an alert will be displayed on screen to the user.


## Project Status
 
 Project is complete and runs successfully.
 
 
 ## Sources
 
 * Marvel Developer API - developer.marvel.com
 * Images (cover images, launch screen image, app icon image) - marvel.com
 * Authorization and Signing - https://developer.marvel.com/documentation/authorization
 * The Data in this Application is Provided by Marvel. © 2014 Marvel
