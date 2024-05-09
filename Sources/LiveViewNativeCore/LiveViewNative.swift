import liveview_native_core
import Foundation

public typealias NodeRef = liveview_native_core.NodeRef
public typealias Payload = [String: Any]

/// Raised when a `Document` fails to parse
public struct ParseError: Error {
    let message: String

    init(message: String) {
        self.message = message
    }
}

/// Represents the various types of events that a `Document` can produce
public enum EventType {
    /// When a document is modified in some way, the `changed` event is raised
    case changed
}

typealias OnChangeCallback = @convention(c) (UnsafeMutableRawPointer?, __ChangeType, NodeRef, __OptionNodeRef) -> ()

public class AttributeVec {
    let ptr: UnsafeRawPointer?
    public let len: Int
    let capacity: Int

    public var isEmpty: Bool { return len == 0 }

    init(ptr: UnsafeRawPointer?, len: Int, capacity: Int) {
        self.ptr = ptr
        self.len = len
        self.capacity = capacity
    }

    convenience init(_ vec: _AttributeVec) {
        self.init(ptr: vec.start, len: Int(vec.len), capacity: Int(vec.capacity))
    }

    deinit {
        let repr = _AttributeVec(start: self.ptr, len: UInt(self.len), capacity: UInt(self.capacity))
        __liveview_native_core$AttributeVec$drop(repr)
    }

    public func toSlice() -> RustSlice<__Attribute> {
        RustSlice(ptr: self.ptr, len: self.len)
    }

    /// Parse a `Document` from the given `String` or `String`-like type
    public func get(index: Int) -> Attribute? {
        if index >= self.len {
            return nil
        } else {
            return Attribute(self.toBufferPointer()[index])
        }
    }

    func toBufferPointer() -> UnsafeBufferPointer<__Attribute> {
        UnsafeBufferPointer(start: self.ptr.map { $0.assumingMemoryBound(to: __Attribute.self) }, count: self.len)
    }
}



/// A `Document` corresponds to the tree of elements in a UI, and supports a variety
/// of operations used to traverse, query, and mutate that tree.
public class Document {
    var repr: __Document
    var handlers: [EventType: (Document, NodeRef) -> Void] = [:]

    init(_ doc: __Document) {
        self.repr = doc
    }

    deinit {
        __liveview_native_core$Document$drop(self.repr)
    }

    /// Parse a `Document` from the given `String` or `String`-like type
    ///
    /// The given text should be a valid HTML-ish document, insofar that the structure should
    /// be that of an HTML document, but the tags, attributes, and their usages do not have to
    /// be valid according to the HTML spec.
    ///
    /// - Parameters:
    ///   - str: The string to parse
    ///
    /// - Returns: A document representing the parsed content
    ///
    /// - Throws: `ParseError` if the content cannot be parsed for some reason
    public static func parse<S: ToRustStr>(_ str: S) throws -> Document {
        var str = str
        return try str.toRustStr({ rustStr in
            let errorPtr = UnsafeMutablePointer<_RustString>.allocate(capacity: 1)
            let result = __liveview_native_core$Document$parse(rustStr.toFfiRepr(), errorPtr)
            if result.is_ok {
                errorPtr.deallocate()
                let doc = Document(__Document(ptr: result.ok_result))
                return doc
            } else {
                let rustString = RustString(errorPtr.move())
                throw ParseError(message: rustString.toString())
            }
        })
    }

    /// Renders this document to a `String` for display and comparison
    public func toString() -> String {
        let str = RustString(__liveview_native_core$Document$to_string(self.repr))
        return str.toString()
    }

    /// Register a callback to be fired when a matching event occurs on this document.
    ///
    /// The given callback receives the document to which the event applies.
    ///
    /// Only one callback per event type is supported. Calling this function multiple times for the
    /// same event will crash.
    ///
    /// - Parameters:
    ///   - event: The `EventType` for which the given callback should be invoked
    ///   - callback: The callback to invoke when an event of the given type occurs
    ///
    public func on(_ event: EventType, _ callback: @escaping (Document, NodeRef) -> ()) {
        precondition(!self.handlers.keys.contains(event))
        self.handlers[event] = callback
    }

    /// Updates this document by calculating the changes needed to make it equivalent to `doc`,
    /// and then applying those changes.
    ///
    /// - Parameters:
    ///   - doc: The document to compare against
    public func merge(with doc: Document) {
        let context = Unmanaged.passUnretained(self).toOpaque()

        let callback: OnChangeCallback = { context, changeType, node, parent in
            let this = Unmanaged<Document>.fromOpaque(context!).takeUnretainedValue()

            if let handler = this.handlers[.changed] {
                switch changeType {
                case .ChangeTypeAdd:
                    handler(this, parent.some_value)
                case .ChangeTypeRemove:
                    handler(this, parent.some_value)
                case .ChangeTypeChange:
                    handler(this, node)
                case .ChangeTypeReplace:
                    handler(this, parent.some_value)
                }
            }
        }

        __liveview_native_core$Document$merge(self.repr, doc.repr, callback, context)
    }
    public static func parseFragmentJson(_ input: String) throws -> Document {
        var input = input
        return try input.toRustStr({ payload in
            let errorPtr = UnsafeMutablePointer<_RustString>.allocate(capacity: 1)
            let result = __liveview_native_core$Document$parse_fragment_json(payload.toFfiRepr(), errorPtr)
            if result.is_ok {
                errorPtr.deallocate()
                let doc = Document(__Document(ptr: result.ok_result))
                return doc
            } else {
                let rustString = RustString(errorPtr.move())
                throw ParseError(message: rustString.toString())
            }
        })
    }
    public static func parseFragmentJson(payload: Payload) throws -> Document {
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        return try parseFragmentJson(String(data: jsonData, encoding: .utf8)!)
    }
    public func mergeFragmentJson (_ input: String) throws {
        var input = input
        let context = Unmanaged.passUnretained(self).toOpaque()

        let callback: OnChangeCallback = { context, changeType, node, parent in
            let this = Unmanaged<Document>.fromOpaque(context!).takeUnretainedValue()

            if let handler = this.handlers[.changed] {
                switch changeType {
                case .ChangeTypeAdd:
                    handler(this, parent.some_value)
                case .ChangeTypeRemove:
                    handler(this, parent.some_value)
                case .ChangeTypeChange:
                    handler(this, node)
                case .ChangeTypeReplace:
                    handler(this, parent.some_value)
                }
            }
        }
        let errorPtr = UnsafeMutablePointer<_RustString>.allocate(capacity: 1)
        let result = input.toRustStr({ payload in
                              __liveview_native_core$Document$merge_fragment_json(self.repr, payload.toFfiRepr(), callback, context, errorPtr)
                          })
            if result.is_ok {
                errorPtr.deallocate()
                //let doc = Document(__Document(ptr: result.ok_result))
                //return doc
            } else {
                let rustString = RustString(errorPtr.move())
                throw ParseError(message: rustString.toString())
            }
    }
    public func mergeFragmentJson (payload: Payload) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        let payload = String(data: jsonData, encoding: .utf8)!
        return try mergeFragmentJson(payload)
    }

    /// Returns a reference to the root node of the document
    ///
    /// The root node is not part of the document itself, but can be used to traverse the document tree top-to-bottom.
    public func root() -> NodeRef {
        return __liveview_native_core$Document$root(self.repr)
    }

    /// Enables indexing of the document by node reference, returning the reified `Node` to which it corresponds
    public subscript(ref: NodeRef) -> Node {
        let node = __liveview_native_core$Document$get(self.repr, ref)
        return Node(doc: self, ref: ref, data: node)
    }

    /// Returns the parent, if there is one, of the node with the given ref.
    public func getParent(_ ref: NodeRef) -> NodeRef? {
        let result = __liveview_native_core$Document$get_parent(self.repr, ref)
        if result.is_some {
            return result.some_value
        } else {
            return nil
        }
    }

    func getChildren(_ ref: NodeRef) -> RustSlice<NodeRef> {
        let slice = __liveview_native_core$Document$children(self.repr, ref)
        return RustSlice(ptr: slice.start, len: Int(slice.len))
    }

    func getAttrs(_ ref: NodeRef) -> AttributeVec {
        let av = __liveview_native_core$Document$attributes(self.repr, ref)
        return AttributeVec(av)
    }
}

/// Represents a node in the document tree
///
/// A node can be one of three types:
///
/// - A root node, which is a special marker node for the root of the document
/// - A leaf node, which is simply text content, cannot have children or attributes
/// - An element node, which can have children and attributes
///
/// A node in a document is uniquely identified by a `NodeRef` for the lifetime of
/// that node in the document. But a `NodeRef` is not a stable identifier when the
/// tree is modified. In some cases the `NodeRef` remains the same while the content
/// changes, and in others, a new node is allocated, so a new `NodeRef` is used.
public class Node: Identifiable {
    /// The type and associated data of this node
    public enum Data {
        case root
        case element(ElementData)
        case leaf(String)
    }

    let doc: Document

    /// The identifier for this node in its `Document`
    public let id: NodeRef
    /// The type and data associated with this node
    public let data: Data
    /// The attributes associated with this node. Returns an empty array if this node is not an element.
    public var attributes: [Attribute] {
        if case .element(let data) = data {
            return data.attributes
        } else {
            return []
        }
    }

    init(doc: Document, ref: NodeRef, data: __Node) {
        self.id = ref
        self.doc = doc
        switch data.ty {
        case .NodeTypeRoot:
            self.data = .root
        case .NodeTypeElement:
            self.data = .element(ElementData(doc: doc, ref: ref, data: data.data.element))
        case .NodeTypeLeaf:
            self.data = .leaf(RustStr(data.data.leaf).toString()!)
        }
    }

    /// Renders this node to a `String`
    public func toString() -> String {
        let str = RustString(__liveview_native_core$Document$node_to_string(self.doc.repr, self.id))
        return str.toString()
    }

    /// Nodes are indexable by attribute name, returning the first attribute with that name
    public subscript(_ name: AttributeName) -> Attribute? {
        return attributes.first { $0.name == name }
    }

    /// A sequence of the children of this node.
    public func children() -> NodeChildrenSequence {
        let children = doc.getChildren(id)
        //print("Node Children: ", children)
        return NodeChildrenSequence(doc: doc, slice: children, startIndex: children.startIndex, endIndex: children.endIndex)
    }

    /// A sequence of this node's children that visits them recursively in depth-first order.
    ///
    /// ## Example
    /// In the following code, the tags are visited in the following order: `a`, `b`, `c`, `d`.
    /// ```swift
    /// let doc = try! Document.parse("<a><b><c /></b><d /></a>")
    /// for node in doc[doc.root()].depthFirstChildren() {
    ///     // ...
    /// }
    /// ```
    /// - Note: The sequence does not include this node. However, if called on the root node of a document (as in the example above), it will include the outermost _element_ because the parser inserts a virtual ``Node/Data-swift.enum/root`` node.
    public func depthFirstChildren() -> NodeDepthFirstChildrenSequence {
        return NodeDepthFirstChildrenSequence(root: self)
    }
}

/// A sequence representing the direct children of a node.
public struct NodeChildrenSequence: Sequence, Collection, RandomAccessCollection {
    public typealias Element = Node
    public typealias Index = Int

    let doc: Document
    let slice: RustSlice<NodeRef>
    public let startIndex: Int
    public let endIndex: Int

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> Node {
        doc[slice[startIndex + position]]
    }
}

/// A sequence of the recursive children of a node, visited in depth-first order.
///
/// See ``Node/depthFirstChildren()``
public struct NodeDepthFirstChildrenSequence: Sequence {
    public typealias Element = Node

    let root: Node

    public func makeIterator() -> Iterator {
        return Iterator(children: [root.children().makeIterator()])
    }

    public struct Iterator: IteratorProtocol {
        public typealias Element = Node

        var children: [NodeChildrenSequence.Iterator]

        public mutating func next() -> Node? {
            if !children.isEmpty {
                if let node = children[children.count - 1].next() {
                    children.append(node.children().makeIterator())
                    return node
                } else {
                    children.removeLast()
                    return self.next()
                }
            } else {
                return nil
            }
        }
    }
}

/// Represents a node in a `Document` which can have children and attributes
public struct ElementData {
    /// An (optional) namespace for the element tag name
    public let namespace: String?
    /// The name of the element tag in the document
    public let tag: String
    /// An array of attributes associated with this element
    public let attributes: [Attribute]

    init(doc: Document, ref: NodeRef, data: __Element) {
        self.namespace = RustStr(data.ns).toString()
        self.tag = RustStr(data.tag).toString()!
        let av = AttributeVec(data.attributes)
        self.attributes = av.toSlice().map { attr in Attribute(attr) }
    }
}

/// An attribute is a named string value associated with an element
public struct Attribute {
    /// The fully-qualified name of the attribute
    public var name: AttributeName
    /// The value of this attribute, if there was one
    public var value: String?

    init(name: AttributeName, value: String?) {
        self.name = name
        self.value = value
    }

    init(_ attribute: __Attribute) {
        let name = AttributeName(namespace: attribute.ns, name: attribute.name)
        let value = RustStr(attribute.value).toString()
        self.init(name: name, value: value)
    }
}
extension Attribute: Identifiable {
    public var id: AttributeName {
        name
    }
}
extension Attribute: Equatable {
    public static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}
extension Attribute: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
    }
}

/// Represents a fully-qualified attribute name
///
/// Attribute names can be namespaced, so rather than represent them as a plain `String`,
/// we use this type to preserve the information for easy accessibility.
public struct AttributeName: RawRepresentable {
    public var namespace: String?
    public var name: String

    /// The textual representation (`namespace:name` if it has a namespace, otherwise just the name) of this attribute name.
    public var rawValue: String {
        if let namespace {
            return "\(namespace):\(name)"
        } else {
            return name
        }
    }

    /// Creates a name by parsing a string, extracting a namespace if present.
    ///
    /// Fails if the string is empty or there are more than two colon-delimited parts.
    public init?(rawValue: String) {
        let parts = rawValue.split(separator: ":")
        switch parts.count {
        case 1:
            self.name = rawValue
        case 2:
            self.namespace = String(parts[0])
            self.name = String(parts[1])
        default:
            return nil
        }
    }

    public init(namespace: String? = nil, name: String) {
        self.namespace = namespace
        self.name = name
    }

    init(namespace: _RustStr, name: _RustStr) {
        let ns = RustStr(namespace)
        let n = RustStr(name)
        if ns.isEmpty {
            self.init(namespace: nil, name: n.toString()!)
        } else {
            self.init(namespace: ns.toString(), name: n.toString()!)
        }
    }
}
extension AttributeName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}
extension AttributeName: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
extension AttributeName: Identifiable {
    public var id: String {
        rawValue
    }
}
extension AttributeName: Equatable {
    public static func == (lhs: AttributeName, rhs: AttributeName) -> Bool {
        return lhs.namespace == rhs.namespace && lhs.name == rhs.name
    }
}
extension AttributeName: Comparable {
    public static func < (lhs: AttributeName, rhs: AttributeName) -> Bool {
        // Both namespaces are nil, then compare by name
        if lhs.namespace == nil && rhs.namespace == nil {
            return lhs.name < rhs.name
        }
        // Neither namespace are nil, compare by namespace, then by name
        if let lhsNs = lhs.namespace, let rhsNs = rhs.namespace {
            if lhsNs != rhsNs {
                return lhsNs < rhsNs
            } else {
                return lhs.name < rhs.name
            }
        }
        // Otherwise, one of the namespaces are nil, and nil namespaces always come first
        return lhs.namespace == nil
    }
}
extension AttributeName: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(namespace)
        hasher.combine(name)
    }
}
