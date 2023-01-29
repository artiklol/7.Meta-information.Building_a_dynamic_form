//
//  Model.swift
//  task_7
//
//  Created by Artem Sulzhenko on 24.01.2023.
//

import Foundation

class Form: Codable {
    let title: String
    let image: String
    let fields: [Field]

    init(title: String, image: String, fields: [Field]) {
        self.title = title
        self.image = image
        self.fields = fields
    }
}

class Field: Codable {
    let title: String
    let name: NameField
    let type: TypeField
    let values: [String: String]?

    init(title: String, name: NameField, type: TypeField, values: [String: String]?) {
        self.title = title
        self.name = name
        self.type = type
        self.values = values
    }
}

 enum TypeField: String, Codable {
    case text = "TEXT"
    case numeric = "NUMERIC"
    case list = "LIST"
 }

enum NameField: String, Codable {
   case text
   case numeric
   case list
}
