//
//  ContentView.swift
//  Parks
//
//  Created by Madison Bunsen on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var parks: [Park] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(parks) { park in
                        NavigationLink(value: park) {
                            ParkRow(park: park)
                        }
                    }
                }
                .padding(.vertical)
                .task {
                    await fetchParks()
                }
            }
            // ✅ The title belongs here, not inside .navigationDestination
            .navigationTitle("National Parks - Madison Bunsen")
            
            // Destination for the navigation
            .navigationDestination(for: Park.self) { park in
                ParkDetailView(park: park)
            }
        }
    }
    
    private func fetchParks() async {
        guard let url = URL(string: "https://developer.nps.gov/api/v1/parks?stateCode=ca&api_key=evNYqkLj6bmJ1hPQZzG0OiIgeqFpq3jC6cuYOr7j") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parksResponse = try JSONDecoder().decode(ParksResponse.self, from: data)
            await MainActor.run {
                self.parks = parksResponse.data
            }
        } catch {
            print("Fetch failed:", error.localizedDescription)
        }
    }
}


struct ParkRow: View {
    let park: Park

    var body: some View {
        
        // Park row
        Rectangle()
            .aspectRatio(4/3, contentMode: .fit)
            .overlay {
                // TODO: Get image url
                let image = park.images.first
                let urlString = image?.url
                let url = urlString.flatMap { string in
                    URL(string: string)
                }
                
                // TODO: Add AsyncImage
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray4)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text(park.name)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .padding()
            }
            .cornerRadius(16)
            .padding(.horizontal)
    }
}
