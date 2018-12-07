import Foundation

extension Int {
    /**
     Returns the radian value for a degree value.
     */
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180
    }
}
