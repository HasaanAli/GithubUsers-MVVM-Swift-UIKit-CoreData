# GithubUsers

TODOs:
1. Network auto retry: Test the custom NetworkMonitor class and pass the retry() closures to it instead of callling retry() in DispatchQueue.main.async(after: ).
2. Make the ImageCache singleton class codable and use it for images. Will require removing image logic from models and CoreData.
3. Write unit tests
4. Improve Api queueing to something better, NSOperation?
