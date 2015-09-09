SMART on FHIR
=============

An **iOS medication list app** using SMART on FHIR via our [iOS SMART on FHIR framework](https://github.com/p2/SMART-on-FHIR-Cocoa).

This example app runs out of the box against our sandbox server.
To download and run you'll need Xcode 7, perform these steps:

1. Checkout the source code:
    
    ```bash
    git clone --recursive https://github.com/p2/SoF-MedList.git
    ```
2. Open the project file `SoF-MedList.xcodeproj` in Xcode 7+.
3. Select an iPhone simulator and press **Run**.

The `master` branch is currently on _Swift 2.0_ and the _May 2015 DSTU 2_ ballot version of FHIR ([`0.5.0`](https://github.com/smart-on-fhir/Swift-SMART/releases/tag/FHIR-0.5.0)).  
Check the `develop` branch for bleeding edge updates, if any, and the [tags](https://github.com/smart-on-fhir/SoF-MedList/releases) for older releases.

### What's Happening?

This is a simple app based on Apple's master/detail view default code.
There are two places where custom code performs interesting tasks:

#### App Delegate

In `AppDelegate.swift` we initialize a (lazy) handle to our SMART client (lines 18-23).
Then, starting on line 39, there are 3 methods that the App delegate provides but mostly just forwards to the SMART client.
The `findMeds:` method constructs a search for medication prescriptions for the selected patient and runs it against the server, as follows:

```swift
MedicationPrescription.search(["patient": id]).perform(...)
```

The last method is needed when choosing to use iOS's Safari instead of a built-in web view.
It is implemented to intercept callbacks when the user returns from the browser after logging in and selecting a patient.

#### Master View Controller

The table view controller subclass `MasterViewController.swift` has a few tweaks to perform UI tasks, such as displaying the patient's name in the button top left.
The most interesting part is the `selectPatient:` method which updates the UI accordingly, calls the App delegate's `selectPatient:` method and when it returns successfully continues to search for all of the patient's medication prescriptions, again using the App delegate and its `findMeds:` method.
It displays an error on failure and on success reloads the table to show the names of the medications.
