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

open class TaskProgress: ObservableObject {
    @Published public var current = 0
    @Published public var total = 1
    
    public var callback: (() -> Void)? = nil
    public var cancelled = false
    
    public init() {
        
    }
    
    public func fraction() -> Double {
        Double(current) / Double(total)
    }
    
    public func percentString() -> String {
        String(format: "%.2f", fraction() * 100) + "%"
    }
    
    @MainActor
    open func inc() {
        current += 1
        
        if current == total {
            logger.debug("Sending download progress callback")
            callback?()
        }
        
        logger.trace("Incremented task progress to \(self.current)")
    }
    
    public func intPercent() -> Int {
        Int((fraction() * 100).rounded())
    }
    
    public func isDone() -> Bool {
        Int(current) >= Int(total)
    }
    
    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
    
    public static func completed() -> TaskProgress {
        TaskProgress(current: 1, total: 1)
    }
    
    public func setFrom(_ other: TaskProgress) {
        current = other.current
        total = other.total
    }
}
