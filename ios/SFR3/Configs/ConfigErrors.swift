//
//  ConfigurationMissingError.swift
//  SFR3
//
//  Created by Luiz SSB on 21/04/25.
//

struct ConfigurationMissingError: Error {
    let name: String
}

struct ConfigurationInvalidError: Error {
    let name: String
    let cause: Error?
    let message: String?
}
