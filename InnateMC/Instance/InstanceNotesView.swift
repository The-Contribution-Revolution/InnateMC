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

struct InstanceNotesView: View {
    @StateObject var editingViewModel: InstanceEditingViewModel
    @StateObject var instance: Instance
    
    var body: some View {
        if editingViewModel.inEditMode {
            TextField("", text: $editingViewModel.notes, prompt: Text(i18n("notes")))
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 50)
                .padding(.leading, 3)
        } else {
            if instance.notes != nil {
                Text(instance.notes!)
                    .font(.body)
                    .frame(minWidth: 50)
                    .padding(.leading, 3)
            }
        }
    }
}
