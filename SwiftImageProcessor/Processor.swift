import Metal
import MetalKit
import simd

struct Processor {
    private let device: MTLDevice
    private let library: MTLLibrary
    
    init() throws {
        guard let libraryPath = Bundle.main.path(forResource: "default", ofType: "metallib") else { throw Error.libraryNotFound }
        guard let device = MTLCreateSystemDefaultDevice() else { throw Error.systemMetalDeviceNotFound }
        
        self.device = device
        self.library = try device.makeLibrary(filepath: libraryPath)
    }
}

extension Processor {
    func run(fileName: String, fileExtension: FileExtension, kernel: Kernel) throws -> MTLTexture {
        guard fileExtension != .unknwon else { throw Error.unsuppoertedExtension }
        
        let commandQueue = device.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        guard let kernelFunction = library.makeFunction(name: kernel.functionName) else {
            throw Error.kernelFunctionNotFound(inputFunction: kernel.functionName, availableFunctions: library.functionNames)
        }
        let computePipelineState = try device.makeComputePipelineState(function: kernelFunction)
        
        let textureLoader = MTKTextureLoader(device: device)
        
        let imageName = fileName + "." + fileExtension.rawValue
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + imageName)
        
        let textureLoaderOption = [
            MTKTextureLoader.Option.allocateMipmaps: NSNumber(value: false),
            MTKTextureLoader.Option.SRGB: NSNumber(value: false)
        ]
        guard let texture = try? textureLoader.newTexture(URL: url, options: textureLoaderOption) else {
            throw Error.imageDataNotFound(name: imageName, path: FileManager.default.currentDirectoryPath)
        }
        
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: texture.width,
            height: texture.height,
            mipmapped: false
        )
        outTextureDescriptor.usage = [.shaderWrite, .shaderRead]
        guard let outTexture = device.makeTexture(descriptor: outTextureDescriptor) else {
            throw Error.failedToMakeTexture
        }
        
        let threads = makeThreadgroups(textureWidth: outTexture.width, textureHeight: outTexture.height)
        
        commandEncoder?.setComputePipelineState(computePipelineState)
        commandEncoder?.setTexture(texture, index: 0)
        commandEncoder?.setTexture(outTexture, index: 1)
        
        for (index, parameter) in kernel.parameters.enumerated() {
            let buffer = device.makeBuffer(bytes: [parameter], length: MemoryLayout<Float>.size, options: [])
            commandEncoder?.setBuffer(buffer, offset: 0, index: index)
        }
        
        commandEncoder?.dispatchThreadgroups(threads.threadgroupsPerGrid, threadsPerThreadgroup: threads.threadsPerThreadgroup)
        commandEncoder?.endEncoding()
        
        let syncEncoder = commandBuffer?.makeBlitCommandEncoder()
        syncEncoder?.synchronize(resource: outTexture)
        syncEncoder?.endEncoding()
        
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        
        return outTexture
    }
}

private extension Processor {
    func makeThreadgroups(textureWidth: Int, textureHeight: Int) -> (threadgroupsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize) {
        let threadSize = 16
        let threadsPerThreadgroup = MTLSizeMake(threadSize, threadSize, 1)
        let horizontalThreadgroupCount = textureWidth / threadsPerThreadgroup.width + 1
        let verticalThreadgroupCount = textureHeight / threadsPerThreadgroup.height + 1
        let threadgroupsPerGrid = MTLSizeMake(horizontalThreadgroupCount, verticalThreadgroupCount, 1)
        
        return (threadgroupsPerGrid: threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}

extension Processor {
    enum Error: Swift.Error, CustomStringConvertible {
        case libraryNotFound
        case systemMetalDeviceNotFound
        case unsuppoertedExtension
        case imageDataNotFound(name: String, path: String)
        case failedToMakeTexture
        case kernelFunctionNotFound(inputFunction: String, availableFunctions: [String])
        
        var description: String {
            switch self {
            case .libraryNotFound: return "default.metallib not found."
            case .systemMetalDeviceNotFound: return "Seems system metal device is unavailable."
            case .unsuppoertedExtension: return "Unsupported file extension is used."
            case .imageDataNotFound(let name, let path): return "'\(name)' doesn't exist in '\(path)'"
            case .failedToMakeTexture: return "Failed to make texture."
            case .kernelFunctionNotFound(let inputFunction, let availableFunctions):
                let listText = availableFunctions.reduce("") { acc, value in
                    return acc + "\(value), "
                }.dropLast(2)
                return "\(inputFunction) is unavailable.\n" + "Available functions: [" + listText + "]"
            }
        }
    }
}
