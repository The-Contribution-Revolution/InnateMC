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

struct InstanceDuplicationSheet: View {
    @StateObject var instance: Instance
    @EnvironmentObject private var launcherData: LauncherData
    
    @Binding var showDuplicationSheet: Bool
    
    @State private var newName = ""
    
    var body: some View {
        VStack {
            // TODO: allow selecting what and what not to duplicate
            Form {
                TextField(i18n("name"), text: $newName)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            HStack {
                Button(i18n("duplicate")) {
                    let newInstance = Instance(
                        name: newName,
                        assetIndex: instance.assetIndex,
                        libraries: instance.libraries,
                        mainClass: instance.mainClass,
                        minecraftJar: instance.minecraftJar,
                        isStarred: false,
                        logo: instance.logo,
                        description: instance.notes,
                        debugString: instance.debugString,
                        arguments: instance.arguments
                    )
                    
                    DispatchQueue.global(qos: .userInteractive).async {
                        do {
                            try newInstance.createAsNewInstance()
                            logger.info("Successfully duplicated instance")
                        } catch {
                            logger.error("Could not duplicate instance \(newName)", error: error)
                            ErrorTracker.instance.error(error: error, description: "Could not duplicate instance \(newName)")
                        }
                    }
                    
                    launcherData.instances.append(newInstance)
                    showDuplicationSheet = false
                }
                .padding()
                
                Button(i18n("cancel")) {
                    showDuplicationSheet = false
                }
                .padding()
            }
        }
        .onAppear {
            newName = "Copy of \(instance.name)" // TODO: localize
        }
    }
}
