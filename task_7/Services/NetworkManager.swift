//
//  NetworkManager.swift
//  task_7
//
//  Created by Artem Sulzhenko on 24.01.2023.
//

import UIKit

class NetworkManager {

    static private let url = "http://test.clevertec.ru/tt/meta/"
    static private let postUrl = "http://test.clevertec.ru/tt/data/"

    static func fetchFormConstructor(completion: @escaping (Form, UIImage) -> Void) {
        guard let url = URL(string: url) else { return }

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

            guard let url = URL(string: result.image) else { return }
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: imageData) else { return }

            DispatchQueue.main.async {
                completion(result, image)
            }
        }.resume()
    }

    static func sendData(parametrs: [String: [String: String]], completion: @escaping ([String: String]) -> Void) {
        guard let url = URL(string: postUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parametrs) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let response = response as? HTTPURLResponse {
                print(response)
            }

            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }

            DispatchQueue.main.async {
                completion(json)
            }

        }.resume()
    }
}
