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

struct InstanceLogoView: View {
    @StateObject var instance: Instance
    
    var body: some View {
        ZStack {
            switch instance.logo.logoType {
            case .file:
                AsyncImage(url: instance.getLogoPath()) {
                    $0.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "tray.circle").resizable()
                }
                
            case .symbol:
                Image(systemName: instance.logo.string)
                    .resizable()
                    .scaledToFit()
                
            case .builtin:
                Image(instance.logo.string)
                    .resizable()
                    .scaledToFit()
                
            }
        }
    }
}
