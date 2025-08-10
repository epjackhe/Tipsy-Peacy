import SwiftUI

struct RadarChart: View {
    var values: [Double]
    var overlayValues: [Double]? = nil

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
            let radius = size * 0.4

            ZStack {
                // Draw rings
                ForEach(0..<5) { i in
                    let scale = Double(i + 1) / 5.0
                    PolygonShape(sides: values.count)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .scaleEffect(CGFloat(scale), anchor: .center)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }
                // Draw axes
                ForEach(0..<values.count) { i in
                    Path { path in
                        path.move(to: center)
                        let angle = -Double.pi/2 + 2.0 * Double.pi * Double(i) / Double(values.count)
                        let end = CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                                          y: center.y + CGFloat(sin(angle)) * radius)
                        path.addLine(to: end)
                    }
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                // Base polygon
                RadarPolygon(values: values, radius: radius, center: center)
                    .fill(Color.blue.opacity(0.25))
                RadarPolygon(values: values, radius: radius, center: center)
                    .stroke(Color.blue, lineWidth: 2)
                // Overlay polygon
                if let overlay = overlayValues {
                    RadarPolygon(values: overlay, radius: radius, center: center)
                        .fill(Color.orange.opacity(0.2))
                    RadarPolygon(values: overlay, radius: radius, center: center)
                        .stroke(Color.orange, lineWidth: 2)
                }
            }
        }
    }
}

struct RadarPolygon: Shape {
    var values: [Double]
    var radius: CGFloat
    var center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let count = values.count
        for i in 0..<count {
            let fraction = values[i] / 5.0
            let r = radius * CGFloat(fraction)
            let angle = -Double.pi/2 + 2.0 * Double.pi * Double(i) / Double(count)
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * r,
                                y: center.y + CGFloat(sin(angle)) * r)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct PolygonShape: Shape {
    var sides: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.size.width, rect.size.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for i in 0..<sides {
            let angle = -Double.pi/2 + 2.0 * Double.pi * Double(i) / Double(sides)
            let pt = CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                             y: center.y + CGFloat(sin(angle)) * radius)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}
