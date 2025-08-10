import Foundation

enum Axis6: String, CaseIterable, Identifiable {
    case sweet = "Sweet"
    case bitter = "Bitter"
    case spirit = "Spirit"
    case sour = "Sour"
    case umami = "Umami"
    case aroma = "Aroma"
    var id: String { rawValue }
}

/// Order matters: Sweet and Sour must be opposite (index 0 opposite index 3 in a hex).
let axisOrder: [Axis6] = [.sweet, .bitter, .spirit, .sour, .umami, .aroma]

struct TasteVector: Equatable {
    /// Values in the same order as axisOrder, each in 0...5, snapped to 0.5
    var values: [Double] { didSet { clampAndSnap() } }

    init(_ values: [Double]) {
        self.values = values
        clampAndSnap()
    }

    mutating func clampAndSnap() {
        values = values.enumerated().map { idx, v in
            let clamped = min(max(v, 0.0), 5.0)
            return (clamped * 2.0).rounded() / 2.0
        }
        // ensure exactly 6 values
        if values.count != 6 { values = Array(values.prefix(6)) + Array(repeating: 0, count: max(0, 6 - values.count)) }
    }

    func value(for axis: Axis6) -> Double {
        let idx = axisOrder.firstIndex(of: axis)!; return values[idx]
    }

    func with(axis: Axis6, newValue: Double) -> TasteVector {
        var copy = self
        let idx = axisOrder.firstIndex(of: axis)!
        copy.values[idx] = newValue
        copy.clampAndSnap()
        return copy
    }
}

struct Drink: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var venue: String? = nil
    var vector: TasteVector
    var notes: String? = nil
}

struct Classic: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var family: String
    var vector: TasteVector
}
