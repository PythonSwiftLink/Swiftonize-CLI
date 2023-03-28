

import Foundation
import ArgumentParser
import Swiftonize


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
        subcommands: [Build.self].sorted(by: {$0._commandName < $1._commandName})
    )
    
    
    
    struct Build: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument() var source: String
        @Argument() var destination: String
        
        func run() async throws {
            print(APP_FOLDER)
            let src = URL(fileURLWithPath: source)

            let filename = src.lastPathComponent.replacingOccurrences(of: ".py", with: "")

            let dst = URL(fileURLWithPath: destination).appendingPathComponent("\(filename).swift")

            let code = try String(contentsOf: src)

            let module = await WrapModule(fromAst: filename, string: code, swiftui: false)
            try module.pySwiftCode.write(to: dst, atomically: true, encoding: .utf8)
        }
        
    }
    
}
