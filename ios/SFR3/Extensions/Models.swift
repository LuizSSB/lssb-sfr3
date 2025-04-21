//
//  Models.swift
//  SFR3
//
//  Created by Luiz SSB on 21/04/25.
//

import Factory

extension WebContentReference {
    static var forWebComponent: WebContentReference {
        let config = Container.shared.webComponentConfiguration()
        switch config.mode {
        case .local:
            return .local(
                htmlFile: config.localFile!,
                directory: config.localDir
            )
        case .remote:
            return .remote("\(config.remoteScheme!)://\(config.remoteHost!)")
        }
    }
}
