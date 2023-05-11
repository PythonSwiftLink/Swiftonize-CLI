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
import PythonLib

fileprivate extension PyPointer {
    
    func callAsFunction(_ string: String) throws -> String {
        //PyObject_Vectorcall(self, args, arg_count, nil)
        let _string = string.pyPointer
        guard let rtn = PyObject_CallOneArg(self, _string) else { throw PythonError.call }
        
        return (try? .init(object: rtn)) ?? ""
    }
}

func build_wrapper(src: Path, dst: Path, site: Path?) async throws {
    
    //let filename = src.lastPathComponent.replacingOccurrences(of: ".py", with: "")
    let filename = src.lastComponentWithoutExtension
    //let code = try String(contentsOf: src)
    let code = try src.read(.utf8)
    
    let module = await WrapModule(fromAst: filename, string: code, swiftui: false)
//    /try module.pySwiftCode.write(to: dst, atomically: true, encoding: .utf8)
    let module_code = module.code.formatted().description
        .replacingOccurrences(of: "Unmanaged < ", with: "Unmanaged<")
        .replacingOccurrences(of: " > .fromOpaque", with: ">.fromOpaque")
    
//    return
    try dst.write(module_code)
    
    if let site = site {
        guard let test_parse: PyPointer = pythonImport(from: "pure_py_parser", import_name: "testParse") else { throw PythonError.attribute }
        do {
            try (site + "\(filename).py").write(test_parse(code), encoding: .utf8)
        }
        
        catch let err as PythonError {
            print(err.localizedDescription)
            err.triggerError("")
        }
        catch let other {
            print(other.localizedDescription)
        }
    }
}
