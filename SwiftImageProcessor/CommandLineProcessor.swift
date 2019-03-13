import Foundation

struct CommandLineProcessor {
    let fileName: String
    let fileExtension: FileExtension
    let kernel: Kernel
    let outFile: String
    
    // TODO: Option implementation
    init() throws {
        let arguments = CommandLine.arguments
        
        let inputFileName: String
        let sepecifyedOutFile: String?
        
        switch arguments.count {
            
        // case for Xcode Debugging
        case 1:
            inputFileName = "landscape.jpg"
            self.kernel = .gray_average
            sepecifyedOutFile = nil
            
        default:
            fatalError()

//      *********************
//        Under Construction
//        case 3:
//            inputFileName = arguments[1]
//            self.kernel = Kernel(name: arguments[2], parameters: [])
//            sepecifyedOutFile = nil
//
//        case 4:
//            inputFileName = arguments[1]
//            self.kernel = Kernel(name: arguments[2], parameters: [])
//            sepecifyedOutFile = arguments[3]
//
//        default:
//            inputFileName = arguments[1]
//            let parameters = arguments[4...].compactMap(Float.init)
//            self.kernel = Kernel(name: arguments[2], parameters: parameters)
//            sepecifyedOutFile = arguments[3]
        }
        
        let components = inputFileName.components(separatedBy: ".")
        
        if components.count == 2 {
            self.fileName = components[0]
            self.fileExtension = FileExtension(rawValue: components[1])
            if let outFile = sepecifyedOutFile {
                self.outFile = outFile
            } else {
                self.outFile = components[0] + "_" + kernel.functionName + "." + components[1]
            }
            
        } else {
            throw Error.invalidFormat
        }
    }
}

extension CommandLineProcessor {
    enum Error: Swift.Error {
        case invalidFormat
    }
}
