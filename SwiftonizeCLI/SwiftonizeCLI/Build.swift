//
//  Build.swift
//  SwiftonizeCLI
//
//  Created by MusicMaker on 04/04/2023.
//

import Foundation
import ArgumentParser
import Swiftonize
import PythonSwiftCore
import PathKit

func build_wrapper(src: Path, dst: Path, site: Path?) async throws {
    
    //let filename = src.lastPathComponent.replacingOccurrences(of: ".py", with: "")
    let filename = src.lastComponentWithoutExtension
    //let code = try String(contentsOf: src)
    let code = try src.read(.utf8)
    
    let module = await WrapModule(fromAst: filename, string: code, swiftui: false)
//    /try module.pySwiftCode.write(to: dst, atomically: true, encoding: .utf8)
    try dst.write(module.pySwiftCode)
    
    if let site = site {
        let test_parse = pythonImport(from: "pure_py_parser", import_name: "testParse").pyPointer
        try (site + "\(filename).py").write(test_parse(code), encoding: .utf8)
        
    }
}
