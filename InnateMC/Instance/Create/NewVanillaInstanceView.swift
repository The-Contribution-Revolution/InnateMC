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

struct NewVanillaInstanceView: View {
    @EnvironmentObject private var launcherData: LauncherData
    @AppStorage("newVanillaInstance.cachedName") var name = NSLocalizedString("new_instance_default", comment: "New Instance")
    @AppStorage("newVanillaInstance.cachedVersion") var cachedVersionId = ""
    
    @Binding var showNewInstanceSheet: Bool
    
    @State private var versionManifest: [PartialVersion] = []
    @State private var showSnapshots = false
    @State private var showBeta = false
    @State private var showAlpha = false
    @State private var selectedVersion: PartialVersion = .createBlank()
    @State private var versions: [PartialVersion] = []
    @State private var showNoNamePopover = false
    @State private var showDuplicateNamePopover = false
    @State private var showInvalidVersionPopover = false
    
    var body: some View {
        VStack {
            Spacer()
            Form {
                TextField(i18n("name"), text: $name).frame(width: 400, height: nil, alignment: .leading).textFieldStyle(.roundedBorder)
                    .popover(isPresented: $showNoNamePopover, arrowEdge: .bottom) {
                        Text(i18n("enter_a_name"))
                            .padding()
                    }
                    .popover(isPresented: $showDuplicateNamePopover, arrowEdge: .bottom) {
                        // TODO: implement
                        Text(i18n("enter_unique_name"))
                            .padding()
                    }
                Picker(i18n("version"), selection: $selectedVersion) {
                    ForEach(versions) { ver in
                        Text(ver.version)
                            .tag(ver)
                    }
                }
                .popover(isPresented: $showInvalidVersionPopover, arrowEdge: .bottom) {
                    Text(i18n("choose_valid_version"))
                        .padding()
                }
                
                Toggle(i18n("show_snapshots"), isOn: $showSnapshots)
                Toggle(i18n("show_old_beta"), isOn: $showBeta)
                Toggle(i18n("show_old_alpha"), isOn: $showAlpha)
            }.padding()
            
            HStack {
                Spacer()
                
                HStack{
                    Button(i18n("cancel")) {
                        showNewInstanceSheet = false
                    }.keyboardShortcut(.cancelAction)
                    Button(i18n("done")) {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if trimmedName.isEmpty { // TODO: also check for spaces
                            showNoNamePopover = true
                            return
                        }
                        
                        if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased()}) {
                            showDuplicateNamePopover = true
                            return
                        }
                        
                        if !versionManifest.contains(where: { $0 == selectedVersion }) {
                            showInvalidVersionPopover = true
                            return
                        }
                        
                        showNoNamePopover = false
                        showDuplicateNamePopover = false
                        showInvalidVersionPopover = false
                        let instance = VanillaInstanceCreator(name: trimmedName, versionUrl: URL(string: selectedVersion.url)!, sha1: selectedVersion.sha1, notes: nil, data: launcherData)
                        do {
                            launcherData.instances.append(try instance.install())
                            name = NSLocalizedString("new_instance_default", comment: "New Instance")
                            cachedVersionId = ""
                            showNewInstanceSheet = false
                        } catch {
                            ErrorTracker.instance.error(error: error, description: "Error creating instance")
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.trailing)
                .padding(.bottom)
                
            }
        }
        .onAppear {
            versionManifest = launcherData.versionManifest
            recomputeVersions()
        }
        .onReceive(launcherData.$versionManifest) {
            versionManifest = $0
            recomputeVersions()
        }
        .onChange(of: showAlpha) { _ in
            recomputeVersions()
        }
        .onChange(of: showBeta) { _ in
            recomputeVersions()
        }
        .onChange(of: showSnapshots) { _ in
            recomputeVersions()
        }
        .onChange(of: selectedVersion) { _ in
            cachedVersionId = selectedVersion.version
        }
    }
    
    func recomputeVersions() {
        if versionManifest.isEmpty {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let newVersions = versionManifest.filter { version in
                return version.type == "old_alpha" && showAlpha ||
                version.type == "old_beta" && showBeta ||
                version.type == "snapshot" && showSnapshots ||
                version.type == "release"
            }
            
            let notContained = !newVersions.contains(selectedVersion)
            
            DispatchQueue.main.async {
                versions = newVersions
                
                if let cached = versions.filter({ $0.version == cachedVersionId}).first {
                    selectedVersion = cached
                } else if notContained {
                    selectedVersion = newVersions.first!
                }
            }
        }
    }
}

#Preview {
    NewVanillaInstanceView(showNewInstanceSheet: .constant(true))
}
