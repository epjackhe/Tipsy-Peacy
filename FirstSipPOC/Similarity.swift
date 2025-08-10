import Foundation

func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
    let dotProduct = zip(a, b).map(*).reduce(0.0, +)
    let magnitudeA = sqrt(a.map { $0 * $0 }.reduce(0.0, +))
    let magnitudeB = sqrt(b.map { $0 * $0 }.reduce(0.0, +))
    guard magnitudeA > 0 && magnitudeB > 0 else { return 0.0 }
    return dotProduct / (magnitudeA * magnitudeB)
}

func closestClassics(for vector: [Double], classics: [Classic], count: Int = 3) -> [Classic] {
    let scored = classics.map { ($0, cosineSimilarity(vector, $0.vector)) }
    return Array(scored.sorted { $0.1 > $1.1 }.prefix(count).map { $0.0 })
}
