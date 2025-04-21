//
//  WebContentReference.swift
//  SFR3
//
//  Created by Luiz SSB on 21/04/25.
//

enum WebContentReference {
    struct InvalidReferenceError: Error {}
    
    case remote(String),
         local(htmlFile: String, directory: String? = nil)
}
