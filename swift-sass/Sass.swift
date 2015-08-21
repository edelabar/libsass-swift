//
//  Sass.swift
//  swift-sass
//
//  Created by Niels de Hoog on 19/08/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

enum SassError: ErrorType {
    case SyntaxError(String)
}

public struct Sass {
    public static func compileFile(path: String, includePath: String? = nil) throws -> String {
        
        let context = sass_make_file_context(path)
        
        if let includePath = includePath {
            let options = sass_file_context_get_options(context)
            sass_option_set_include_path(options, includePath)
        }
        
        sass_compile_file_context(context)
        
        if let error = String.fromCString(sass_context_get_error_message(context)) {
            throw SassError.SyntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!
        
        sass_delete_file_context(context)
        
        return outputString
    }
    
    public static func compile(scss: String, includePath: String? = nil) throws -> String {
        
        var cString = scss.cStringUsingEncoding(NSUTF8StringEncoding)!
        
        // copy string to allow libsass to take ownership
        let pointer = UnsafeMutablePointer<Int8>.alloc(cString.count)
        memcpy(pointer, cString, cString.count)
        
        let context = sass_make_data_context(pointer)
        
        if let includePath = includePath {
            let options = sass_data_context_get_options(context)
            sass_option_set_include_path(options, includePath)
        }
        
        sass_compile_data_context(context)
        
        if let error = String.fromCString(sass_context_get_error_message(context)) {
            throw SassError.SyntaxError(error)
        }
        
        let output = sass_context_get_output_string(context)
        let outputString = String.fromCString(output)!

        sass_delete_data_context(context)
        
        return outputString
    }
}