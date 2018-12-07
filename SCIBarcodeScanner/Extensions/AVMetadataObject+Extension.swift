import AVFoundation

extension AVMetadataObject.ObjectType {

    /**
     List of all supported code types.
     */
    public static let all = [
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.face,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.qr,
        AVMetadataObject.ObjectType.upce
    ]

    /**
     List of codes that should minimally be supported for applications related to trading of actual goods.
     */
    public static let minimal = [
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.qr,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.dataMatrix
    ]
}
