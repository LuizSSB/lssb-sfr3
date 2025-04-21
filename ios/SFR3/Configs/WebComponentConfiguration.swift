//
//  Configuration.swift
//  SFR3
//
//  Created by Luiz SSB on 21/04/25.
//

import Foundation
import Factory

struct WebComponentConfiguration: Codable, Equatable {
    enum Mode: String, Codable {
        case remote, local
    }
    
    enum Route: Equatable, Codable, Hashable {
        case itemRoot,
             itemDetail(String)
        
        var path: String {
            switch self {
            case .itemRoot: return "/item"
            case let .itemDetail(item): return "/item/\(item)"
            }
        }
    }
    
    let remoteScheme: String?
    let remoteHost: String?
    let localDir: String?
    let localFile: String?
    let mode: Mode
    
    static func fromInfo() throws -> Self {
        guard let raw = Bundle.main.object(
            forInfoDictionaryKey: "WebComponentConfig"
        ) as? [String:String]
        else { throw ConfigurationMissingError(name: "WebComponentConfig") }
        
        do {
            let config = try WebComponentConfiguration(jsonLikeObject: raw)
            switch config.mode {
            case .remote:
                guard config.remoteHost != nil && config.remoteScheme != nil
                else {
                    throw ConfigurationInvalidError(
                        name: "WebComponentConfig",
                        cause: nil,
                        message: "remote stuff missing"
                    )
                }
            case .local:
                guard config.localFile != nil
                else {
                    throw ConfigurationInvalidError(
                        name: "WebComponentConfig",
                        cause: nil,
                        message: "local file missing"
                    )
                }
            }
            return config
        } catch {
            throw ConfigurationInvalidError(
                name: "WebComponentConfig",
                cause: error,
                message: nil
            )
        }
    }
}

extension Container {
    var webComponentConfiguration: Factory<WebComponentConfiguration> {
        self {
            do {
                return try .fromInfo()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        .singleton
    }
}
