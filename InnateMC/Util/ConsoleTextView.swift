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

struct ConsoleTextView: NSViewRepresentable {
    typealias NSViewType = NSTextView
    
    var text: String
    var layoutManager: NSLayoutManager
    var textContainer: NSTextContainer
    var font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.minSize = NSSize(width: 200, height: 50)
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = font
        textView.alignment = .natural
        textView.string = text
        textView.allowsUndo = false
        textView.textContainer = textContainer
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        textContainer.layoutManager = layoutManager
        nsView.string = text
        nsView.font = font
        nsView.textContainer = textContainer
    }
}

#Preview {
    let ints = Array(1...10)
    let layoutManager = NSLayoutManager()
    
    let textContainer: NSTextContainer = {
        let cont = NSTextContainer()
        layoutManager.addTextContainer(cont)
        layoutManager.allowsNonContiguousLayout = true
        
        return cont
    }()
    
    return VStack(spacing: 0) {
        ForEach(ints, id: \.self) { i in
            ConsoleTextView(
                text: "This is console text \(i)",
                layoutManager: layoutManager,
                textContainer: textContainer
            )
        }
    }
}
