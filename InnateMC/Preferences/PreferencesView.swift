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

struct PreferencesView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    var body: some View {
        TabView(selection: $launcherData.selectedPreferenceTab) {
            RuntimePreferencesView()
                .tag(SelectedPreferenceTab.runtime)
                .tabItem {
                    Label("runtime", systemImage: "cup.and.saucer")
                }
            AccountsPreferencesView()
                .tag(SelectedPreferenceTab.accounts)
                .tabItem {
                    Label("accounts", systemImage: "person.circle")
                }
            UiPreferencesView()
                .tag(SelectedPreferenceTab.ui)
                .tabItem {
                    Label("user_interface", systemImage: "paintbrush.pointed")
                }
            MiscPreferencesView()
                .tag(SelectedPreferenceTab.misc)
                .tabItem {
                    Label("misc", systemImage: "slider.horizontal.3")
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                launcherData.initializePreferenceListenerIfNot()
            }
        }
    }
}
