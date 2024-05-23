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

class MicrosoftAccountViewModel: ObservableObject {
    @Published var showMicrosoftAccountSheet = false
    @Published var message = i18n("authenticating_with_microsoft")
    @Published var error: MicrosoftAuthError = .noError
    
    @MainActor func error(_ error: MicrosoftAuthError) {
        ErrorTracker.instance.error(error: error, description: NSLocalizedString("error_during_microsoft_add", comment: "Caught error while adding microsoft account"))
        self.error = error
    }
    
    @MainActor func prepareAndOpenSheet(launcherData: LauncherData) {
        showMicrosoftAccountSheet = true
        launcherData.accountManager.msAccountViewModel = self
        launcherData.accountManager.createAuthWindow().showWindow(InnateMCApp.self)
    }
    
    @MainActor func closeSheet() {
        showMicrosoftAccountSheet = false
        error(.noError)
        message = i18n("authenticating_with_microsoft")
    }
    
    @MainActor func setAuthWithXboxLive() {
        message = i18n("authenticating_with_xbox_live")
    }
    
    @MainActor func setAuthWithXboxXSTS() {
        message = i18n("authenticating_with_xbox_xsts")
    }
    
    @MainActor func setAuthWithMinecraft() {
        message = i18n("authenticating_with_minecraft")
    }
    
    @MainActor func setFetchingProfile() {
        message = i18n("fetching_profile")
    }
}
