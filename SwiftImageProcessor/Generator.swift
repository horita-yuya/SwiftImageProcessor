import Metal

struct Generator {
    private let texture: MTLTexture
    private let pixelFormat: PixelFormat
    
    init(texture: MTLTexture, pixelFormat: PixelFormat? = nil) {
        self.texture = texture
        self.pixelFormat = pixelFormat ?? PixelFormat(pixelFormat: texture.pixelFormat)
    }
    
    func run(fileName: String) throws {
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        let memorySize = MemoryLayout<UInt8>.size
        let capacity = texture.width * texture.height * pixelFormat.bitsPerPixel / memorySize
        
        let bytesPerRow = pixelFormat.bitsPerPixel / memorySize * texture.width
        var imageBytes = Array<UInt8>(repeating: 0, count: capacity)
        
        texture.getBytes(&imageBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        let provider = CGDataProvider(data: NSData(bytes: &imageBytes, length: imageBytes.count * memorySize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmap = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue)
        let renderingIntent = CGColorRenderingIntent.perceptual
        let imageReference = CGImage(
            width: texture.width,
            height: texture.height,
            bitsPerComponent: pixelFormat.bitsPerComponent,
            bitsPerPixel: pixelFormat.bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmap,
            provider: provider!,
            decode: nil,
            shouldInterpolate: false,
            intent: renderingIntent
        )
        
        let destinationUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + fileName)
        guard let destination = CGImageDestinationCreateWithURL(destinationUrl as CFURL, kUTTypeJPEG, 1, nil) else {
            throw Error.failedToCreateDestination(destinationPath: destinationUrl.absoluteString)
        }
        CGImageDestinationAddImage(destination, imageReference!, nil)
        CGImageDestinationFinalize(destination)
    }
}

extension Generator {
    enum Error: Swift.Error, CustomStringConvertible {
        case failedToCreateDestination(destinationPath: String)
        
        var description: String {
            switch self {
            case .failedToCreateDestination(let destinationPath): return "Failed to create destination to '\(destinationPath)'"
            }
        }
    }
}
