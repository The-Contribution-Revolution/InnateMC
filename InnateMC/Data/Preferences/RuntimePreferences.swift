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

import Foundation

public class RuntimePreferences: Codable, ObservableObject {
    @Published public var defaultJava: SavedJavaInstallation = .systemDefault
    @Published public var minMemory = 1024
    @Published public var maxMemory = 1024
    @Published public var javaArgs = ""
    @Published public var valid = true
    
    public init() {
        
    }
    
    public init(_ prefs: RuntimePreferences) {
        defaultJava = prefs.defaultJava
        minMemory = prefs.minMemory
        maxMemory = prefs.maxMemory
        javaArgs = prefs.javaArgs
        valid = prefs.valid
    }
    
    public func invalidate() -> RuntimePreferences {
        valid = false
        return self
    }
    
    public static func invalid() -> RuntimePreferences {
        .init().invalidate()
    }
}
