//
//  ClickableGameView.swift
//  onegb
//
//  Created by Ezagor on 13.12.2023.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool // Determine if the message is from the user or the system
}
struct ClickableGameView: View {
    let header: String
    let description: String
    let options: [String]
    let correctOption: String
    let brand: String
    let banner:String
    @State private var selectedOption: String?
    @State private var messages: [String] = []
    @State private var gamePlayed = false
    @State private var metabytePoints: Int = 0

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.self) { message in
                    MessageBubble(message: message, isUser: message.contains("You are correct") || message.contains("Not quite right"))
                }
            }
            
            if !gamePlayed {
                // Game question and options
                VStack {
                    Text(header)
                        .font(.headline)
                        .padding()
                    
                    Image(banner) // Replace with your actual image or gif name in the assets
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                    
                    Text(description)
                        .font(.body)
                        .padding()
                    
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            self.selectedOption = option
                        }) {
                            Text(option)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(self.selectedOption == option ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 2)
                    }
                    
                    Button("BUL KAZAN") {
                        guard let selected = selectedOption else { return }
                        let result = checkAnswer(selected: selected)
                        messages.append(result.message)
                        metabytePoints += result.points
                        gamePlayed = true
                        // Append system message about Metabyte points
                        let systemMessage = "\(brand) rewarded you \(result.points) Metabyte points!"
                        messages.append(systemMessage)
                    }
                    .disabled(selectedOption == nil)
                    .padding()
                    .background(selectedOption != nil ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            // Display total metabyte points
            Text("Total Metabyte Points: \(metabytePoints)")
                .padding()
        }
        .padding()
        .navigationTitle("Game Chat")
    }
    
    private func checkAnswer(selected: String) -> (message: String, points: Int) {
        if selected == correctOption {
            return ("You are correct!", 10)
        } else {
            return ("Not quite right, but it's okay.", 1)
        }
    }
}

struct MessageBubble: View {
    var message: String
    var isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            Text(message)
                .padding()
                .background(isUser ? Color.blue : Color.secondary.opacity(0.1))
                .foregroundColor(isUser ? .white : .black)
                .cornerRadius(15)
            if !isUser { Spacer() }
        }
        .transition(.move(edge: isUser ? .trailing : .leading))
    }
}

struct ClickableGameView_Previews: PreviewProvider {
    static var previews: some View {
        ClickableGameView(
            header: "Which is the correct one",
            description: "Make your choice!",
            options: ["Option A", "Option B", "Option C"],
            correctOption: "Option B",
            brand: "BoşYok",
            banner: "soru1"
        )
    }
}
