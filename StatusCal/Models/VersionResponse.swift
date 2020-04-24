//
//  VersionResponse.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 23.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

struct VersionResponse: Decodable {
    
    let lastVersion: Float
    
    enum CodingKeys: String, CodingKey {
        case lastVersion = "last_version"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lastVersion = try container.decode(Float.self, forKey: .lastVersion)
    }
}
