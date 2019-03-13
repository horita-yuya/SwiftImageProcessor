import Metal

struct PixelFormat {
    let pixelFormat: MTLPixelFormat
    let bitsPerComponent: Int
    let bitsPerPixel: Int
    
    init(pixelFormat: MTLPixelFormat) {
        self.pixelFormat = pixelFormat
        
        switch pixelFormat {
        case .rgba8Unorm:
            self.bitsPerComponent = 8
            self.bitsPerPixel = 32
            
        case .bgra8Unorm:
            self.bitsPerComponent = 8
            self.bitsPerPixel = 32
            
        default:
            fatalError("Unsupported pixelformat is used.")
        }
    }
}
