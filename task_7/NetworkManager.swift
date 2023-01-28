//
//  NetworkManager.swift
//  task_7
//
//  Created by Artem Sulzhenko on 24.01.2023.
//

import Foundation

class NetworkManager {

//    static private let url = "http://test.clevertec.ru/tt/meta/"
    static private let test = "https://mocki.io/v1/489e8788-1a8a-4206-aa93-78698ffe6d86"

    static func fetchFormConstructor(completion: @escaping (Form) -> Void) {
           guard let url = URL(string: test) else { return }

           URLSession.shared.dataTask(with: url) { (data, response, error) in
               if let error = error {
                   print(error.localizedDescription)
                   return
               }

               if let response = response as? HTTPURLResponse {
                   print(response.statusCode)
               }

               guard let data = data else { return }
               guard let result = try? JSONDecoder().decode(Form.self, from: data) else { return }

               DispatchQueue.main.async {
                   completion(result)
               }
           }.resume()
       }
}
