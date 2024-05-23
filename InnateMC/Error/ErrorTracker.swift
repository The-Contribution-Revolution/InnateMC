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

public class ErrorTracker: ObservableObject {
    static var instance = ErrorTracker()
    private var windowControllerTemp: ErrorTrackerWindowController? = nil
    
    @Published var errors: [ErrorTrackerEntry] = []
    
    private var windowController: ErrorTrackerWindowController {
        if let windowControllerTemp {
            return windowControllerTemp
        }
        
        windowControllerTemp = .init()
        
        return windowControllerTemp!
    }
    
    func error(error: Error? = nil, description: String) {
        if let error {
            logger.error(description, error: error)
        } else {
            logger.error("\(description)")
        }
        
        errors.append(ErrorTrackerEntry(type: .error, description: description, error: error, timestamp: CFAbsoluteTime()))
    }
    
    func nonEssentialError(description: String) {
        errors.append(ErrorTrackerEntry(type: .nonEssentialError, description: description, timestamp: CFAbsoluteTime()))
    }
    
    func showWindow() {
        windowController.showWindow(InnateMCApp.self)
    }
}
