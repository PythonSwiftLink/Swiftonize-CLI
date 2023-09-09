

import Foundation
import ArgumentParser
import Swiftonize
import PythonSwiftCore
import PathKit
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxParser

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
        subcommands: [Build.self, BuildAll.self, TestSyntax.self, Generics.self].sorted(by: {$0._commandName < $1._commandName})
    )
    
    
    
    struct Build: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument(transform: { p -> Path in .init(p) }) var source
        @Argument(transform: { p -> Path in .init(p) }) var destination
        @Option(transform: { p -> Path? in .init(p) }) var site
        @Flag() var beeware: Bool = false
        
        
        func run() async throws {
            
            let dst = destination + "\(source.lastComponentWithoutExtension).swift"

            try await build_wrapper(src: source, dst: dst, site: site, beeware: beeware)
            
        }
        
    }
    
    struct Generics: AsyncParsableCommand {
        
        func run() async throws {
            //            let tester = PyCallbacks()
            //            try tester.test0(string: "")
            //tester.test1(string: "guard nargs > 1, let _args_ = _args_, let s = s else { throw PythonError.call }")
            
            //            tester.test2(string: """
            //            .init(withArgs: "hmmmmmm") { s, _args_, nargs in
            //                return nil
            //            }
            //            """)
            
                let decl = GenerateCallables().code
                let code = decl.formatted().description
                    .replacingOccurrences(of: " < A", with: "<A")
                    .replacingOccurrences(of: " < R:", with: "<R:")
                    .replacingOccurrences(of: "on < ", with: "on<")
                    .replacingOccurrences(of: "Python > ", with: "Python>")
                    .replacingOccurrences(of: " > (", with: ">(")
                print(code)
            try Path("/Users/musicmaker/Documents/GitHub/PythonSwiftCore/Sources/PythonSwiftCore/PyPointer+PyCall.swift").write(code)
        }
        
    }
    
    struct TestSyntax: AsyncParsableCommand {
        
        func run() async throws {
//            let tester = PyCallbacks()
//            try tester.test0(string: "")
            //tester.test1(string: "guard nargs > 1, let _args_ = _args_, let s = s else { throw PythonError.call }")
            
//            tester.test2(string: """
//            .init(withArgs: "hmmmmmm") { s, _args_, nargs in
//                return nil
//            }
//            """)
        }
        
    }
    
    struct BuildAll: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument(transform: { p -> Path in .init(p) }) var source
        @Argument(transform: { p -> Path in .init(p) }) var destination
        @Option(transform: { p -> Path? in .init(p) }) var site
        @Flag() var beeware: Bool = false
        
        func run() async throws {
            print(source)
            
            var src: Path
            
            switch source {
            case let sym where source.isSymlink:
                src = try sym.symlinkDestination()
            case let dir where source.isDirectory:
                src = dir
            default: fatalError("\(source.string) is not a directory")
            }
            
            let wrappers = try SourceFilter(root: src)
            
            for file in wrappers.sources {
                
                switch file {
                case .pyi(let path):
                    try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site, beeware: beeware)
                case .py(let path):
                    try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site, beeware: beeware)
                case .both(_, let pyi):
                    try await build_wrapper(src: pyi, dst: file.swiftFile(destination), site: site, beeware: beeware)
                }
                
//                guard file.isFile, file.extension == "py" else { continue }
//                print(file)
//                let dst = destination + "\(file.lastComponentWithoutExtension).swift"
//                try await build_wrapper(src: file, dst: dst, site: site)
                
            }
            
        }
        
    }
    
    struct SwiftAutoWrap: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument(transform: { p -> Path in .init(p) }) var source
        @Argument(transform: { p -> Path in .init(p) }) var destination
        @Option(transform: { p -> Path? in .init(p) }) var site
        @Flag() var beeware: Bool = false
        
        func run() async throws {
            print(source)
            
            var src: Path
            
            switch source {
            case let sym where source.isSymlink:
                src = try sym.symlinkDestination()
            case let dir where source.isDirectory:
                src = dir
            default: fatalError("\(source.string) is not a directory")
            }
            
            let wrappers = try SourceFilter(root: src)
            
            for file in wrappers.sources {
                
                switch file {
                case .pyi(let path):
                    try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site, beeware: beeware)
                case .py(let path):
                    try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site, beeware: beeware)
                case .both(_, let pyi):
                    try await build_wrapper(src: pyi, dst: file.swiftFile(destination), site: site, beeware: beeware)
                }
                
                //                guard file.isFile, file.extension == "py" else { continue }
                //                print(file)
                //                let dst = destination + "\(file.lastComponentWithoutExtension).swift"
                //                try await build_wrapper(src: file, dst: dst, site: site)
                
            }
            
        }
        
    }
}
