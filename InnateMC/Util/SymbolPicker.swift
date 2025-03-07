// MIT License
//
// Copyright (c) 2022 Yubo Qin & Lakr Aream
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Adapted by InnateMC from <https://github.com/xnth97/SymbolPicker>
//

//
//  SymbolPicker.swift
//  SymbolPicker
//
//  Created by Yubo Qin on 2/14/22.
//
import SwiftUI

/// A simple and cross-platform SFSymbol picker for SwiftUI.
public struct SymbolPicker: View {
    // MARK: - Properties
    @Environment(\.presentationMode) private var presentationMode
    @Binding public var symbol: String
    
    private let symbols = SFSymbolsList.getAll()
    
    private static var gridDimension = 48.0
    private static var symbolSize = 24.0
    private static var symbolCornerRadius = 8.0
    private static var unselectedItemBackgroundColor: Color = .clear
    private static var selectedItemBackgroundColor: Color = .accentColor
    
    private static var backgroundColor: Color = .clear
    
    // MARK: - Public Init
    /// Initializes `SymbolPicker` with a string binding that captures the raw value of user-selected SFSymbol
    /// - Parameter symbol: String binding to store user selection
    public init(symbol: Binding<String>) {
        _symbol = symbol
    }
    
    @State private var searchText = ""
    
    private var searchableSymbolGrid: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("search", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18))
                    .disableAutocorrection(true)
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            Divider()
            
            symbolGrid
        }
    }
    
    private var symbolGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.gridDimension, maximum: Self.gridDimension))]) {
                ForEach(symbols.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button {
                        symbol = thisSymbol
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        if thisSymbol == symbol {
                            Image(systemName: thisSymbol)
                                .font(.system(size: Self.symbolSize))
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                                .background(Self.selectedItemBackgroundColor)
                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: thisSymbol)
                                .font(.system(size: Self.symbolSize))
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                                .background(Self.unselectedItemBackgroundColor)
                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    public var body: some View {
        searchableSymbolGrid
            .frame(width: 540, height: 320, alignment: .center)
    }
}

#Preview {
    SymbolPicker(symbol: .constant("square.and.arrow.up"))
}
