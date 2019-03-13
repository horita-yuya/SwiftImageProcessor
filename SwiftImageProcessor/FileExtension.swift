enum FileExtension: String {
    case jpg
    case png
    case unknwon
    
    init(rawValue: String) {
        switch rawValue {
        case "jpg": self = .jpg
        case "jpeg": self = .jpg
        case "png": self = .png
            
        // Use @unknown in the future
        default: self = .unknwon
        }
    }
}
