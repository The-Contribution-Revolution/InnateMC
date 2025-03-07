//
// Copyright © 2022 InnateMC and contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses
//

import SwiftUI

struct AddOfflineAccountView: View {
    @Binding var showSheet: Bool
    @State var onCommit: (String) -> Void
    
    @State private var username = ""
    @State private var showBlankPopover = false
    
    var body: some View {
        VStack {
            Form {
                TextField("username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .popover(isPresented: $showBlankPopover, arrowEdge: .bottom) {
                        Text("enter_a_username")
                            .padding()
                    }
                    .padding()
            }
            HStack {
                if !isValidMinecraftUsername(username) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    
                    Text("invalid_username")
                }
                
                Spacer()
                
                Button("cancel") {
                    showSheet = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("done") {
                    if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showBlankPopover = true
                    } else {
                        onCommit(username)
                        showSheet = false
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(maxWidth: 350)
    }
    
    private func isValidMinecraftUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        let disallowedWords = ["minecraft", "mojang", "admin", "administrator"]
        
        if username.count < 3 || username.count > 16 {
            return false
        }
        
        if !username.allSatisfy({ allowedCharacters.contains(UnicodeScalar(String($0))!) }) {
            return false
        }
        
        let lowercaseUsername = username.lowercased()
        
        if disallowedWords.contains(where: { lowercaseUsername.contains($0) }) {
            return false
        }
        
        return true
    }
}
