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

public class InstanceEditingViewModel: ObservableObject {
    @Published var inEditMode = false
    @Published var name = ""
    @Published var synopsis = ""
    @Published var notes = ""
    
    public func start(from instance: Instance) {
        name = instance.name
        synopsis = instance.synopsis ?? ""
        notes = instance.notes ?? ""
        inEditMode = true
    }
    
    public func commit(to instance: Instance, showNoNamePopover: Binding<Bool>, showDuplicateNamePopover: Binding<Bool>, data launcherData: LauncherData) {
        showNoNamePopover.wrappedValue = false
        showDuplicateNamePopover.wrappedValue = false
        inEditMode = false
        instance.notes = notes == "" ? nil : notes
        instance.synopsis = synopsis == "" ? nil : synopsis
        
        if name != instance.name && !name.isEmpty {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedName.isEmpty {
                showNoNamePopover.wrappedValue = true
                return
            }
            
            if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased()}) {
                showDuplicateNamePopover.wrappedValue = true
                return
            }
            
            instance.renameAsync(to: name)
            logger.info("Successfully edited instance \(instance.name)")
        }
    }
}
