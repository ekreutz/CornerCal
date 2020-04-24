//
//  String.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 24.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//
import Foundation


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    func uppercaseLast(count: Int) -> String {
        let index = self.index(self.endIndex, offsetBy: -2)
        let uppercasedString = String(self[index...]).uppercased()
        return self.dropLast(2) + uppercasedString
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    mutating func uppercaseLast(count: Int) {
        self = self.uppercaseLast(count: count)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment:"")
    }
}
