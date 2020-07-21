//
//  ContentView.swift
//  SwiftUIApis
//
//  Created by Lucas Spusta on 7/21/20.
//

import SwiftUI

struct ItunesResponse: Codable {
    var results: [ItunesResult]
}

struct ItunesResult: Codable {
    var trackId: Int
    var trackName : String
    var collectionName: String
}

struct ContentView: View {
    @State private var results = [ItunesResult]()
    var body: some View {
        NavigationView {
            VStack {
                List(results, id: \.trackId) { item in
                    VStack(alignment: .leading) {
                        Text(item.trackName)
                            .font(.headline)
                        Text(item.collectionName)
                
                    }
                }.onAppear(perform: loadMusicData)
                
                Button(action: {

                    guard let ItunesResultEncoded = try? JSONEncoder().encode(results) else {
                        print("Failed to encode results")
                        return
                    }
                    
                    let url = URL(string: "Your Post Api")!
                    var request = URLRequest(url: url)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = ItunesResultEncoded
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        // handle the result here.
                        if let data = data {
                            if let decodedResponse = try? JSONDecoder().decode(ItunesResponse.self, from: data) {
                                // we have good data – go back to the main thread
                                DispatchQueue.main.async {
                                    // update our UI
                                    self.results = decodedResponse.results
                                }

                                // everything is good, so we can exit
                                return
                            }
                        }

                        // if we're still here it means there was a problem
                        print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                    }.resume()
                    
                }) {
                    Text("Call Post Api")
                }
            }.navigationTitle("Itunes Results")

           
        }
        .navigationViewStyle(StackNavigationViewStyle())
        

    }
    
    func loadMusicData() {
        guard let url = URL(string: "https://itunes.apple.com/search?term=Charlie+Puth&entity=song") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // step 4
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(ItunesResponse.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.results = decodedResponse.results
                    }

                    // everything is good, so we can exit
                    return
                }
            }

            // if we're still here it means there was a problem
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
