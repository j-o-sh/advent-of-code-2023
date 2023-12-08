protocol Traversable<T> {
    associatedtype T
    var from: T { get }
    var to: T { get }
}

func shortestPath<V: Equatable, U: Traversable<V>>(
    to: V,
    from: V,
    in edges: [U]
) -> [U]? {
    typealias MetaEdge = ( edge: U, path: [U] )

    // 1. assing a path to the edges to capture distance to target
    let graph = edges.map { ( edge: $0, path: [U]() ) }

    // 2. find starting edges
    let target = graph.filter({ $0.edge.to == to })

    
    func nextStep(node: V, consider: [MetaEdge], root: MetaEdge?) -> [U]? {
        // print("\(root) ?? => \(node) (\(consider))")
        // print("...")
        for var current in consider {
            // 3.2 update distance path on the current edge
            if let root { 
                var path = [root.edge]
                path.append(contentsOf: root.path)
                path.append(contentsOf: current.path)
                current.path = path
            }

            // 3.4 return early if a direct path has been found
            if current.edge.from == from {
                var path = [current.edge]
                path.append(contentsOf: current.path)
                return path
            }

            // 3.3 find all connected edges
            let connected = graph.filter { $0.edge.to == current.edge.from }

            // 3.3 ? ignore visited

            // Step 4, recurse with subtree
            for next in connected {
                return nextStep(
                    node: next.edge.from, 
                    consider: connected, 
                    root: current)
            }
        }

        return nil
    }

    // 3. ...
    return nextStep(node: to, consider: target, root: nil)
}

