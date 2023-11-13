//
//  APICaller.swift
//  NexaNews
//
//  Created by Jesse Hough on 11/3/23.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")
        static let searchUrlString = "https://newsapi.org/v2/everything?sortedBy=popularity&apiKey=8722f03b48cc48a5b7e887b0e62cbb46&q="
        static let technologyNewsURL = URL(string: "https://newsapi.org/v2/everything?q=Technology&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")
        static let sportsNewsURL = URL(string: "https://newsapi.org/v2/everything?q=Sports&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")
        static let scienceNewsURL = URL(string: "https://newsapi.org/v2/everything?q=Science&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")
        
    }
    
    // Default source to US
    public var sourceId = "us"
    private var defaultID = ""
    
    public func setSourceId(id:String){
        sourceId = id
    }
    
   
    
    private init() {}
    
    

    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        
        guard let filteredURL = URL(string:
                                    "https://newsapi.org/v2/top-headlines?country="+sourceId+"&apiKey=8722f03b48cc48a5b7e887b0e62cbb46") else { return  }
        
        
        let task = URLSession.shared.dataTask(with: filteredURL ?? url) { data, _, error in
            if let error = error{
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
    
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let urlString = Constants.searchUrlString + query
        guard let url = URL(string: urlString) else {
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: url ) { data, _, error in
            if let error = error{
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
    
    public func getTechnologyNews(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.technologyNewsURL else {
            return
        }
        let filteredURL = URL(string:
                                        "https://newsapi.org/v2/top-headlines?country="+sourceId+"&category=Technology&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")
        
        

        let task = URLSession.shared.dataTask(with: filteredURL ?? url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
    
    public func getSportsNews(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.sportsNewsURL else {
            return
        }
        
        let filteredURL = URL(string:
                                        "https://newsapi.org/v2/top-headlines?country="+sourceId+"&category=sports&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")

        let task = URLSession.shared.dataTask(with: filteredURL ?? url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
    
    public func getScienceNews(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.scienceNewsURL else {
            return
        }
        let filteredURL = URL(string:
                                        "https://newsapi.org/v2/top-headlines?country="+sourceId+"&category=Science&apiKey=8722f03b48cc48a5b7e887b0e62cbb46")

        let task = URLSession.shared.dataTask(with: filteredURL ?? url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.articles))
                } catch {
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

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}
