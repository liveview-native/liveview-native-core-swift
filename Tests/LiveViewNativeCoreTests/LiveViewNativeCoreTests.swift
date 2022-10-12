import XCTest
@testable import LiveViewNativeCore

class MyContext {
    var didChange = false
}

final class LiveViewNativeCoreTests: XCTestCase {
    func testIntegration() throws {
        let context = MyContext()
        let input = """
<html lang="en">
    <head>
        <meta charset="utf-8" />
    </head>
    <body class="new-value" class="main">
        some content
    </body>
</html>
"""
        let doc1 = try Document.parse(input)
        doc1.on(.changed) { doc in
            context.didChange = true
        }
        let rendered1 = doc1.toString()
        XCTAssertEqual(input, rendered1)

        let updated = """
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="title" content="Hello World" />
    </head>
    <body class="new-value" class="main">
        new content
    </body>
</html>
"""
        let doc2 = try Document.parse(updated)
        let rendered2 = doc2.toString()
        XCTAssertEqual(updated, rendered2)

        doc1.merge(with: doc2)

        XCTAssertEqual(context.didChange, true)

        let finalRender = doc1.toString()
        XCTAssertEqual(finalRender, rendered2)
    }
    
    func testDepthFirstIterator() throws {
        let input = "<a><b><c /></b><d /></a>"
        let doc = try Document.parse(input)
        let rootNode = doc[doc.root()]
        let tags = rootNode.depthFirstChildren().map {
            if case .element(let data) = $0.data {
                return data.tag
            } else {
                fatalError()
            }
        }
        XCTAssertEqual(tags, ["a", "b", "c", "d"])
    }
}
