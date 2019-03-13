import Foundation
import Metal
import MetalKit

do {
    let commandLine = try CommandLineProcessor()
    let processor = try Processor()
    let texture = try processor.run(
        fileName: commandLine.fileName,
        fileExtension: commandLine.fileExtension,
        kernel: commandLine.kernel
    )
    let generator = Generator(texture: texture)
    
    try generator.run(fileName: commandLine.outFile)
    print("Success")
    
} catch {
    print(error)
}
