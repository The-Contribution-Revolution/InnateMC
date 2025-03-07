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

struct InstanceRuntimeView: View {
    @EnvironmentObject private var launcherData: LauncherData
    @StateObject var instance: Instance
    
    @State private var valid = false
    @State private var selectedJava = SavedJavaInstallation.systemDefault
    
    var body: some View {
        VStack {
            Form {
                Toggle("Override default runtime settings", isOn: $instance.preferences.runtime.valid)
                    .padding(.bottom, 5)
                
                Picker("java", selection: $selectedJava) {
                    PickableJavaVersion(installation: .systemDefault)
                    
                    ForEach(launcherData.javaInstallations) {
                        PickableJavaVersion(installation: $0)
                    }
                }
                .disabled(!valid)
                
                Group {
                    TextField("default_min_mem", value: $instance.preferences.runtime.minMemory, formatter: NumberFormatter())
                    
                    TextField("default_max_mem", value: $instance.preferences.runtime.maxMemory, formatter: NumberFormatter())
                    
                    TextField("default_java_args", text: $instance.preferences.runtime.javaArgs)
                }
                .textFieldStyle(.roundedBorder)
                .disabled(!valid)
            }
            .padding(.all, 16)
            
            Spacer()
        }
        .onAppear {
            valid = instance.preferences.runtime.valid
            selectedJava = instance.preferences.runtime.defaultJava
        }
        .onChange(of: selectedJava) { newValue in
            instance.preferences.runtime.defaultJava = newValue
        }
        .onReceive(instance.preferences.runtime.$valid) {
            logger.debug("Changed runtime preferences validity for \(instance.name) to \($0)")
            
            if !$0 && valid {
                instance.preferences.runtime = .init(launcherData.globalPreferences.runtime).invalidate()
                selectedJava = launcherData.globalPreferences.runtime.defaultJava
            }
            
            valid = $0
        }
    }
}
