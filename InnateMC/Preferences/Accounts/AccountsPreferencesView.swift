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

struct AccountsPreferencesView: View {
    @StateObject private var msAccountViewModel = MicrosoftAccountViewModel()
    @EnvironmentObject private var launcherData: LauncherData
    
    @State private var showAddOfflineSheet = false
    @State private var cachedAccounts: [UUID: any MinecraftAccount] = [:]
    @State private var cachedAccountsOnly: [AdaptedAccount] = []
    @State private var selectedAccountIds: Set<UUID> = []
    
    var body: some View {
        VStack {
            Table(cachedAccountsOnly, selection: $selectedAccountIds) {
                TableColumn("name", value: \.username)
                TableColumn("type", value: \.type.rawValue)
                    .width(max: 100)
            }
            
            HStack {
                Spacer()
                
                Button("add_offline") {
                    showAddOfflineSheet = true
                }
                .padding()
                
                Button("add_microsoft") {
                    msAccountViewModel.prepareAndOpenSheet(launcherData: launcherData)
                }
                .padding()
                
                Button("delete_selected") {
                    for id in selectedAccountIds {
                        launcherData.accountManager.accounts.removeValue(forKey: id)
                    }
                    
                    selectedAccountIds = []
                    
                    DispatchQueue.global(qos: .utility).async {
                        self.launcherData.accountManager.saveThrow() // TODO: handle error
                    }
                }
                .disabled(selectedAccountIds.isEmpty)
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            cachedAccounts = launcherData.accountManager.accounts
            cachedAccountsOnly = Array(cachedAccounts.values).map({ AdaptedAccount(from: $0)})
        }
        .onReceive(launcherData.accountManager.$accounts) {
            cachedAccounts = $0
            cachedAccountsOnly = Array($0.values).map({ AdaptedAccount(from: $0)})
        }
        .onReceive(msAccountViewModel.$showMicrosoftAccountSheet) {
            if !$0 {
                launcherData.accountManager.msAccountViewModel = nil
            }
        }
        .sheet(isPresented: $showAddOfflineSheet) {
            AddOfflineAccountView(showSheet: $showAddOfflineSheet) {
                let acc = OfflineAccount.createFromUsername($0)
                launcherData.accountManager.accounts[acc.id] = acc
                
                DispatchQueue.global(qos: .utility).async {
                    launcherData.accountManager.saveThrow() // TODO: handle error
                }
            }
        }
        .sheet(isPresented: $msAccountViewModel.showMicrosoftAccountSheet) {
            HStack {
                if msAccountViewModel.error == .noError {
                    VStack {
                        Text(msAccountViewModel.message)
                    }
                    .padding()
                } else {
                    VStack {
                        Text(msAccountViewModel.error.localizedDescription).padding()
                        Button("Close") {
                            msAccountViewModel.closeSheet()
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .frame(idealWidth: 400)
        }
    }
}

#Preview {
    AccountsPreferencesView()
}

class AdaptedAccount: Identifiable {
    var id: UUID
    var username: String
    var type: MinecraftAccountType
    
    init(from acc: any MinecraftAccount) {
        id = acc.id
        username = acc.username
        type = acc.type
    }
}
