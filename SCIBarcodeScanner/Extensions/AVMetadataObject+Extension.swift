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

    /** Function for mapping the AVMetadataObject.ObjectType like ZXBarcodeFormat from ZXingObjC Framework
     - Returns: Type as String
    */
    func mapBarcode() -> String {
        switch self {
            case .aztec: return "AZTEC"
            case .code39: return "CODE_39"
            case .code93: return "CODE_93"
            case .code128: return "CODE_128"
            case .dataMatrix: return "DATA_MATRIX"
            case .ean8: return "EAN_8"
            case .ean13: return "EAN_13"
            case .itf14: return "ITF"
            case .upce: return "UPC_E"
            case .pdf417: return "PDF_417"
            case .qr: return "QR_CODE"
            case .face: return "FACE"
            case .code39Mod43: return "CODE_39_MODE_43"
            case .interleaved2of5: return "INTERLEAVED_2_OF_5"
            //case kBarcodeFormatMaxiCode: return "MAXICODE";
            //case kBarcodeFormatRSS14: return "RSS_14";
            //case kBarcodeFormatRSSExpanded: return "RSS_EXPANDED";
            //case kBarcodeFormatUPCA: return "UPC_A";
            //case kBarcodeFormatUPCEANExtension: return "UPC_EAN_EXTENSION";
            default: return self.rawValue
        }
    }

}
