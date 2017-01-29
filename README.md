# Shawshank
"I guess it comes down to a simple choice, really. Get busy testing or get busy crying."

## API Examples
### Swift
```swift
Shawshank.take { (components: URLComponents) in
    return components.host == "www.example.com" && components.port == 82
}.fixture(JSONDataFixture(["test":"json"]))
```
```swift
Shawshank.take(matching: .scheme("http") && .host("www.example.com")).httpStatus(.notPermitted)
```
```swift
let json = Bundle(for: ShankPublicAPITests.self).json(named: "test")
Shawshank.take(matching: .scheme("http") && .host("www.example.com")).fixture(json)
```

### Objective-C
```objc
SHKResponse *testResponse = [SHKResponse new];
testResponse.httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.testRequest.URL statusCode:101 HTTPVersion:nil headerFields:nil];

[[SHKShawshank takeWithRequestPredicate:^BOOL(NSURLRequest *_Nonnull request ) {
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    return [components.host isEqualToString:@"www.example.com"] && [components.path isEqualToString:@"/path/to"];
}] withResponse:testResponse];
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


