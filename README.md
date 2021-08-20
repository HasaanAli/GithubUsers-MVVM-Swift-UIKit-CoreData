# GithubUsers - MVVM-Swift-UIKit-CoreData

A simple app which uses Github's REST api to show the list of github users.

It allows searching/filtering of table data. Tapping a row would show the detail screen with additional info.

Noticeable items:
1. Swift 5 with iOS 13, UIKit, AutoLayout.
2. It uses protocols for list items. 
3. Codable for parsing json into User objects and async image loading.
4. MVVM for separating View and business logic.
5. Coredata for persisting users items fetched from API. Two contexts are used: main and background context.
6. First data saved in the database (if any) is displayed, then (in parallel) new data is fetched from the backend.
7. Check internet availability to show No Internet banner. 
8. Automatically retry loading data once the connection is available.
9. Extensive unit tests for business logic and coredata with In-Memory database store.

