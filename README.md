SMART on FHIR
=============

An **iOS sample app** using SMART on FHIR via the [iOS SMART on FHIR framework](https://github.com/smart-on-fhir/Swift-SMART).

This project requires XCode 11+ for use of Swift Package Manager (SPM).


## Installation

1. Checkout the source code:
    
    ```bash
    git clone --recursive https://github.com/smart-on-fhir/SoF-Demo.git
    ```
2. Open the project file `SoF-Demo.xcodeproj` in Xcode 11+.
3. Select an iPhone simulator and press **Run**.

The `master` branch is currently on _Swift 5.0_ and the _R4_ (`4.0.0-a53ec6ee1b`) version of FHIR ([version `4.0.0` of the SMART framework](https://github.com/smart-on-fhir/Swift-SMART/releases/tag/4.0.0)).  
Check the `develop` branch for bleeding edge updates, if any, and the [tags](https://github.com/smart-on-fhir/SoF-Demo/releases) for older releases.


## What's Happening?

This app allows you to **specify to which FHIR server** you want to connect (bookmark icon top right) and will then let you log in.
During login you'll be selecting a patient, after which a handful of resource types belonging to this very patient will be downloaded.

There are two places where custom code performs interesting tasks:

### App Delegate

Sets up an `EndpointProvider` instance that defines which FHIR endpoints (servers) will be available in the app.
Right now these are hardcoded, starting at line 25 in `AppDelegate.swift`.

The app delegate also listens to OAuth2 callbacks in `application(_:open:options:)` since we'll be using an embedded Safari View Controller to perform the OAuth dance.

### Master View Controller

This class is totally overblown and performs these things, aside from setting up the UI:

- Choose the endpoint with `selectEndpoint()` (~ line 101), which displays a list of available endpoints as configured in the app delegate
- Login and select a patient with `selectPatient()` (~ line 139), which works once an endpoint has been selected and hands off to the SMART client's `authorize()` method
- Once a patient has been selected, loads all resources of the selected patient with `loadResources()` (~ line 179); this method performs a FHIR `search` operation for all resource types that have been defined in `EndpointProvider`

In the end, you'll see a list of FHIR resource types and the number of resources available to this patient.
The app will only load the first page of search results, so the number of resources may be capped at 50.

**NOTE** that not all servers support searching for patients without specifying search parameters, hence the native patient list may be empty.

### List and Detail View Controller

These are handed resources to either show them in a list or display their JSON representation in full.
