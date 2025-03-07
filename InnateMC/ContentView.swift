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

struct ContentView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    private static let nullUuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    @State private var searchTerm = ""
    @State private var starredOnly = false
    @State private var isSidebarHidden = false
    @State private var showNewInstanceSheet = false
    @State private var selectedInstance: Instance? = nil
    @State private var selectedAccount = ContentView.nullUuid
    @State private var cachedAccounts: [AdaptedAccount] = []
    @State private var showDuplicateInstanceSheet = false
    @State private var showDeleteInstanceSheet = false
    @State private var showExportInstanceSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(i18n("search"), text: $searchTerm)
                    .padding(.trailing, 8)
                    .padding(.leading, 10)
                    .padding(.vertical, 9)
                    .textFieldStyle(.roundedBorder)
                
                List(selection: $selectedInstance) {
                    ForEach(launcherData.instances) { instance in
                        if ((!starredOnly || instance.isStarred) && instance.matchesSearchTerm(searchTerm)) {
                            InstanceNavigationLink(instance: instance, selectedInstance: $selectedInstance)
                                .tag(instance)
                                .padding(.all, 4)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .onMove { indices, newOffset in
                        launcherData.instances.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .toolbar {
                    ToolbarItemGroup {
                        createSidebarToolbar()
                    }
                }
            }
            .sheet(isPresented: $showNewInstanceSheet) {
                NewInstanceView(showNewInstanceSheet: $showNewInstanceSheet)
            }
            .sheet(isPresented: $showDeleteInstanceSheet) {
                InstanceDeleteSheet(showDeleteSheet: $showDeleteInstanceSheet, selectedInstance: $selectedInstance, instanceToDelete: selectedInstance!)
            }
            .sheet(isPresented: $showDuplicateInstanceSheet) {
                InstanceDuplicationSheet(instance: selectedInstance!, showDuplicationSheet: $showDuplicateInstanceSheet)
            }
            .sheet(isPresented: $showExportInstanceSheet) {
                InstanceExportSheet(showExportSheet: $showExportInstanceSheet, instance: selectedInstance!)
            }
            .onReceive(launcherData.$instances) { newValue in
                if let selectedInstance {
                    if !newValue.contains(where: { $0 == selectedInstance }) {
                        self.selectedInstance = nil
                    }
                }
            }
            .navigationTitle(i18n("instances_title"))
            
            Text(i18n("select_an_instance"))
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .bindInstanceFocusValue(selectedInstance)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                createTrailingToolbar()
            }
            ToolbarItemGroup(placement: .primaryAction) {
                createPrimaryToolbar()
            }
        }
    }
    
    @ViewBuilder
    func createSidebarToolbar() -> some View {
        Spacer()
        
        Button {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        } label: {
            Image(systemName: "sidebar.leading")
        }
        
        Toggle(isOn: $starredOnly) {
            Image(systemName: starredOnly ? "star.fill" : "star")
        }
        .help(i18n("show_only_starred"))
        
        Button {
            showNewInstanceSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .onReceive(launcherData.$newInstanceRequested) { req in
            if req {
                showNewInstanceSheet = true
                launcherData.newInstanceRequested = false
            }
        }
    }
    
    @ViewBuilder
    func createPrimaryToolbar() -> some View {
        Button {
            showDeleteInstanceSheet = true
        } label: {
            Image(systemName: "trash")
        }
        .disabled(selectedInstance == nil)
        .help(i18n("delete"))
        
        Button {
            showDuplicateInstanceSheet = true
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .disabled(selectedInstance == nil)
        .help(i18n("duplicate"))
        
        Button {
            showExportInstanceSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(true)
        .help(i18n("share_or_export"))
        
        Button {
            if launcherData.launchedInstances.contains(where: { $0.0 == selectedInstance! }) {
                launcherData.killRequestedInstances.append(selectedInstance!)
            } else {
                launcherData.launchRequestedInstances.append(selectedInstance!)
            }
        } label: {
            if let selectedInstance {
                if launcherData.launchedInstances.contains(where: { $0.0 == selectedInstance }) {
                    Image(systemName: "square.fill")
                } else {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
            } else {
                Image(systemName: "arrowtriangle.forward.fill")
            }
        }
        .disabled(selectedInstance == nil)
        .help(i18n("launch"))
        
        Button {
            if launcherData.editModeInstances.contains(where: { $0 == selectedInstance! }) {
                launcherData.editModeInstances.removeAll(where: { $0 == selectedInstance! })
            } else {
                launcherData.editModeInstances.append(selectedInstance!)
            }
        } label: {
            if let selectedInstance {
                if launcherData.editModeInstances.contains(where: { $0 == selectedInstance }) {
                    Image(systemName: "checkmark")
                } else {
                    Image(systemName: "pencil")
                }
            } else {
                Image(systemName: "pencil")
            }
        }
        .disabled(selectedInstance == nil)
        .help(i18n("edit"))
    }
    
    @ViewBuilder
    func createTrailingToolbar() -> some View {
        Spacer()
        
        Picker(i18n("account"), selection: $selectedAccount) {
            Text(i18n("no_account_selected"))
                .tag(ContentView.nullUuid)
            
            ForEach(cachedAccounts) { value in
                HStack(alignment: .center) {
                    AsyncImage(url: URL(string: "https://crafatar.com/avatars/" + value.id.uuidString + "?overlay&size=16"), content: { $0 }) {
                        Image("steve")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    
                    Text(value.username)
                }
                .background(.ultraThickMaterial)
                .padding(.all)
                .tag(value.id)
            }
        }
        .frame(height: 40)
        .onAppear {
            selectedAccount = launcherData.accountManager.currentSelected ?? ContentView.nullUuid
            cachedAccounts = Array(launcherData.accountManager.accounts.values).map { AdaptedAccount(from: $0) }
        }
        .onReceive(launcherData.accountManager.$currentSelected) {
            selectedAccount = $0 ?? ContentView.nullUuid
        }
        .onChange(of: selectedAccount) { newValue in
            launcherData.accountManager.currentSelected = newValue == ContentView.nullUuid ? nil : newValue
            DispatchQueue.global(qos: .utility).async {
                launcherData.accountManager.saveThrow()
            }
        }
        .onReceive(launcherData.accountManager.$accounts) {
            cachedAccounts = Array($0.values).map {
                AdaptedAccount(from: $0)
            }
        }
        
        Button {
            launcherData.selectedPreferenceTab = .accounts
            if #available(macOS 13, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        } label: {
            Image(systemName: "person.circle")
        }
        .help("manage_accounts")
    }
}

extension NavigationView {
    @ViewBuilder
    func bindInstanceFocusValue(_ i: Instance?) -> some View {
        if #available(macOS 13, *) {
            focusedValue(\.selectedInstance, i)
        } else {
            self
        }
    }
}
