//
//  MessageInBoxView.swift
//  onegb
//
//  Created by Ezagor on 13.12.2023.
//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

import SwiftUI

// Represents a single chat message.
struct ChatMessageGPT: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let date: Date
}

// Represents the response from OpenAI API.
struct APIResponse: Decodable {
    struct Message: Decodable {
        let role: String
        let content: String
    }
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: APIResponse.Message
    let index: Int
}

struct MessageInBoxView: View {
    @State private var messages: [ChatMessageGPT] = [ChatMessageGPT(id: UUID(), text: "Welcome to the chat!", isUser: false, date: Date())]
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
            List(messages) { message in
                HStack {
                    if message.isUser {
                        Spacer()
                        Text(message.text)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text(message.text)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            
            HStack {
                TextField("Type your message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                
                Button(action: {
                    self.sendMessage()
                }) {
                    Text("Send")
                }
            }.padding()
        }
    }
    
    func sendMessage() {
        let newMessage = ChatMessageGPT(id: UUID(), text: userInput, isUser: true, date: Date())
        messages.append(newMessage)
        callOpenAIWithText(userInput)
        userInput = ""
    }
    
    func callOpenAIWithText(_ text: String) {
        // Replace with your actual OpenAI API URL
        let url = URL(string: "https://api.openai.com/v1/engines/davinci/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the JSON body with the parameters for the API call
        let body: [String: Any] = [
            "prompt": text,
            "max_tokens": 150
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error: cannot create JSON from body")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error: did not receive data")
                return
            }
            
            DispatchQueue.main.async {
                self.handleResponse(data)
            }
        }.resume()
    }
    
    func handleResponse(_ data: Data) {
        do {
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            if let messageContent = decodedResponse.choices.first?.message.content {
                let systemMessage = ChatMessageGPT(id: UUID(), text: messageContent, isUser: false, date: Date())
                messages.append(systemMessage)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct MessageInBoxView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInBoxView()
    }
}

