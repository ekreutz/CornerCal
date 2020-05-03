//
//  Bundle.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 25.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Foundation

extension Bundle {
    private static var bundle: Bundle!

    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "app_lang")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
}
