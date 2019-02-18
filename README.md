![](https://img.shields.io/github/release/atetlaw/shawshank.svg?style=flat)
# Shawshank
"I guess it comes down to a simple choice, really. Get busy testing or get busy crying."

https://www.youtube.com/watch?v=djigcpyzBUQ

As seen in [Testing Tips & Tricks](https://developer.apple.com/videos/play/wwdc2018/417/?time=480) from WWDC2018 Using an `URLProtocol` subclass is a great way to mock responses from network calls in unit tests, but it can be laborious to setup. The goal of Shawshank was to make mocking a network response a one-liner.

It does 2 things: creates a way to match network requests, and specifies what sort of response to return if the match is true.

## Installation
### Carthage

In your `Cartfile` use:

```
github "atetlaw/shawshank"
```

Shawshank only needs to be added to your unit testing target not your app's main target. Remember to add the [Carthage run script phase](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to your testing target, as well as adding `Shawshank.framework` to your `Link Binaries With Libraries` phase (Just click on the `+` button, the `Add Other...` button, and select the `Shawshank.framework` file in the `Carthage/Build` folder.)

### Cocoapods

Add `pod 'Shawshank'` to your `Podfile`, but limit it to your testing target like so:

```
target 'MyAppTests' do
    pod 'Shawshank'
end
```
Where `MyAppTests` is the name of your app's unit test target. Then run a `pod install`.

## API Examples
### Swift
```swift
// Match any requests to `http:www.example.com` and return the HTTP status: Not Permitted
Shawshank.take(matching: .scheme("http") && .host("www.example.com")).httpStatus(.notPermitted)
```

```swift
let json = Bundle(for: ShankPublicAPITests.self).json(named: "test")
Shawshank.take(matching: .scheme("http") && .host("www.example.com")).fixture(json)
```

```swift
Shawshank.take { (components: URLComponents) in
    return components.host == "www.example.com" && components.port == 82
}.fixture(JSONDataFixture(["test":"json"]))
```

## Unit Test Example
```swift
func testShawshankMatchingDataTaskRespondingWithJSONDataFixture() {
    let testRequest = URLRequest(url: URL(string: "http://www.example.com")!)
    
    Shawshank.take(matching: .scheme("http") && .host("www.example.com")).fixture(JSONDataFixture(["test":"json"]))
    
    let expect = expectation(description: "response successful")
    URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
        guard let httpResponse = response as? HTTPURLResponse else { return }
        XCTAssertNil(error)
        XCTAssertEqual(httpResponse.statusCode, 200)
        XCTAssertNotNil(data)
        
        guard let data = data else { XCTFail(); return }
        guard let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, String> else { XCTFail(); return }
            
        XCTAssertEqual(json?["test"], "json")
        expect.fulfill()
    }.resume()
        
    waitForExpectations(timeout: 1, handler: nil)
}
```

## Ackowledgments

* The original aricle: https://nshipster.com/nsurlprotocol/
* https://www.raywenderlich.com/59982/nsurlprotocol-tutorial
* http://swiftandpainless.com/an-easy-way-to-stub-nsurlsession/

### Inspiration

* https://github.com/AliSoftware/OHHTTPStubs
* https://github.com/kylef/Mockingjay

