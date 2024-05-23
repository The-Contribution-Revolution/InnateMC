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

enum MicrosoftAuthError: Error {
    case noError,
         microsoftCouldNotConnect,
         microsoftInvalidResponse,
         xboxCouldNotConnect,
         xboxInvalidResponse,
         xstsCouldNotConnect,
         xstsInvalidResponse,
         minecraftCouldNotConnect,
         minecraftInvalidResponse,
         profileCouldNotConnect,
         profileInvalidResponse
    
    var localizedDescription: String {
        switch (self) {
        case .noError:
            "No error!"
            
        case .microsoftCouldNotConnect:
            "Could not connect to Microsoft authentication server"
            
        case .microsoftInvalidResponse:
            "Invalid response received from Microsoft authentication server"
            
        case .xboxCouldNotConnect:
            "Could not connect to Xbox Live authentication server"
            
        case .xboxInvalidResponse:
            "Invalid response received from Xbox Live authentication server"
            
        case .xstsCouldNotConnect:
            "Could not connect to Xbox XSTS authentication server"
            
        case .xstsInvalidResponse:
            "Invalid response received from Xbox XSTS authentication server"
            
        case .minecraftCouldNotConnect:
            "Could not connect to Minecraft authentication server"
            
        case .minecraftInvalidResponse:
            "Invalid response received from Minecraft authentication server"
            
        case .profileCouldNotConnect:
            "Could not connect to Minecraft profile server"
            
        case .profileInvalidResponse:
            "Invalid response received from Minecraft profile server"
            
        }
    }
}
