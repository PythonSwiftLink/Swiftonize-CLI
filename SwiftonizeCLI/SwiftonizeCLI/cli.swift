

import Foundation
import ArgumentParser
//import Swiftonize
import PythonSwiftCore
import PathKit

func DEBUG_PRINT(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    print(items, separator: separator, terminator: terminator)
#endif
}


//let APP_FOLDER = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first!.appendingPathComponent("PythonSwiftLinkCLI")

let APP_FOLDER = (Bundle.main.executableURL!).deletingLastPathComponent()


var PYTHON_EXTRA_MODULES : [String] {
    [
        APP_FOLDER.appendingPathComponent("python-extra").path,
        //(SWIFT_TOOLS + "src" ).string
    ]
}

@main
struct SwiftonizeCLI: AsyncParsableCommand {
    init() {
        //        try await checkSwiftTools()
                PythonHandler.shared.defaultRunning.toggle()
    }
    
    
    static let configuration = CommandConfiguration(
        abstract: "SwiftonizeCLI",
        version: "0.0.1",
        subcommands: [Build.self, BuildAll.self].sorted(by: {$0._commandName < $1._commandName})
    )
    
    
    
    struct Build: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument(transform: { p -> Path in .init(p) }) var source
        @Argument(transform: { p -> Path in .init(p) }) var destination
        @Option(transform: { p -> Path? in .init(p) }) var site
        
        func run() async throws {
            
            let dst = destination + "\(source.lastComponentWithoutExtension).swift"

            try await build_wrapper(src: source, dst: dst, site: site)
            
        }
        
    }
    
    struct BuildAll: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument(transform: { p -> Path in .init(p) }) var source
        @Argument(transform: { p -> Path in .init(p) }) var destination
        @Option(transform: { p -> Path? in .init(p) }) var site
        
        func run() async throws {
            print(source)
            for file in source {
                
                guard file.isFile, file.extension == "py" else { continue }
                print(file)
                let dst = destination + "\(file.lastComponentWithoutExtension).swift"
                try await build_wrapper(src: file, dst: dst, site: site)
                
            }
            
        }
        
    }
    
    
}
