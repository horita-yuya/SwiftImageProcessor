enum Kernel {
    case gray_average
    case gray_common
    case gray_bt709
    case gray_bt601
    
    case gaussian(sigma: Float)
    case gaussian_three_dim
    case gaussian_five_dim
    
    case beauty(sigma: Float, luminanceSigma: Float)
    case bilateral(sigma: Float, luminanceSigma: Float)
    case median
    
    case derivatives
    case sobel
    case prewitt
    
    case laplace
    case laplace_eight_surrounding
    
    case unknown(name: String, parameters: [Float])
    
    init(name: String, parameters: [Float]) {
        switch name {
        case "gray_average": self = .gray_average
        case "gray_common": self = .gray_common
        case "gray_bt709": self = .gray_bt709
        case "gray_bt601": self = .gray_bt601
            
        case "gaussian": self = .gaussian(sigma: parameters.first ?? 1)
        case "gaussian_three_dim": self = .gaussian_three_dim
        case "gaussian_five_dim": self = .gaussian_three_dim
            
        case "beauty":
            self = parameters.count == 2
                ? .beauty(sigma: parameters[0], luminanceSigma: parameters[1])
                : .beauty(sigma: 1, luminanceSigma: 1)
            
        case "bilateral":
            self = parameters.count == 2
                ? .bilateral(sigma: parameters[0], luminanceSigma: parameters[1])
                : .bilateral(sigma: 1, luminanceSigma: 1)
            
        case "median": self = .median
            
        case "derivatives": self = .derivatives
        case "sobel": self = .sobel
        case "prewitt": self = .prewitt
            
        case "laplace": self = .laplace
        case "laplace_eight_surrounding": self = .laplace_eight_surrounding
            
        default: self = .unknown(name: name, parameters: parameters)
        }
    }
}

extension Kernel {
    var functionName: String {
        switch self {
        case .gray_average: return "gray_average"
        case .gray_common: return "gray_common"
        case .gray_bt709: return "gray_bt709"
        case .gray_bt601: return "gray_bt601"
            
        case .gaussian: return "gaussian"
        case .gaussian_three_dim: return "gaussian_three_dim"
        case .gaussian_five_dim: return "gaussian_five_dim"
            
        case .bilateral: return "bilateral"
        case .beauty: return "beauty"
            
        case .median: return "median"
        case .derivatives: return "derivatives"
        case .sobel: return "sobel"
        case .prewitt: return "prewitt"
            
        case .laplace: return "laplace"
        case .laplace_eight_surrounding: return "laplace_eight_surrounding"
            
        case .unknown(let name, _): return name
        }
    }
    
    var parameters: [Float] {
        switch self {
        case .gaussian(let sigma): return [sigma]
        case .bilateral(let sigma, let luminanceSigma): return [sigma, luminanceSigma]
        case .beauty(let sigma, let luminanceSigma): return [sigma, luminanceSigma]
        case .unknown(_, let parameters): return parameters
            
        // I want to use @unknown attribute in the future.
        default: return []
        }
    }
}
