//
//  APICaller.swift
//  DiffableDataSource
//
//  Created by Esraa Eid on 15/10/2021.
//

import Foundation



final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadLinesURL = URL(string: "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=4435399e0203452ba983391f629f3ed6")
    }
    
    private init() {}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void){
        guard let url = Constants.topHeadLinesURL else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                    catch {
                        completion(.failure(error))
                    }
                }
            }
        task.resume()
        }
    }

//Models
 
struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Hashable {
    var id : UUID? = UUID()
    let source: Source
    let title : String
    let description : String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    
    // 1
    func hash(into hasher: inout Hasher) {
      // 2
      hasher.combine(id)
    }

    // 3
    static func == (lhs: Article, rhs: Article) -> Bool {
      lhs.id == rhs.id
    }

}
struct Source: Codable {
    let name: String
}
