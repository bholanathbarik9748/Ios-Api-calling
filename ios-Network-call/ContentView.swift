//
//  ContentView.swift
//  ios-Network-call
//
//  Created by Bholanath Barik on 23/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user : GitHubUser?;
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")){ image in
                    image
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .frame(width: 500,height: 350)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                } placeholder: {
                        ProgressView();
                }
            
            Text(user?.login ?? "Name PlaceHoler")
                .padding()
            
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
        }
        .padding()
        .task {
            do {
                user = try await getUser();
            }catch{
                
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/bholanathbarik9748";
        
        guard let url = URL(string: endpoint) else {
            throw GHerror.InvalidUrl
        }
        
        let (data , response) = try await URLSession.shared.data(from: url);
        
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else {
            throw GHerror.InvalidResponse
        }
        
        do{
            let decorder = JSONDecoder();
            decorder.keyDecodingStrategy = .convertFromSnakeCase
            return try decorder.decode(GitHubUser.self, from: data);
        } catch{
            throw GHerror.InvalidData;
        }
    }
    
    func postUser() async throws -> String {
            let endpoint = "https://jsonplaceholder.typicode.com/posts"
            
            guard let url = URL(string: endpoint) else {
                throw GHerror.InvalidUrl
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let newUser = GitHubUser(login: "bholanathbarik9748", avatarUrl: "https://avatars.githubusercontent.com/u/583231", bio: "This is a bio")
            
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(newUser)
            
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                throw GHerror.InvalidResponse
            }
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                return responseString
            } else {
                throw GHerror.InvalidData
            }
        }
}

#Preview {
    ContentView()
}

struct GitHubUser: Decodable, Encodable {
    let login : String
    let avatarUrl: String
    let bio : String
}

enum GHerror: Error {
    case InvalidUrl
    case InvalidResponse
    case InvalidData
}
