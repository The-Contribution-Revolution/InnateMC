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

struct InstanceConsoleView: View {
    var instance: Instance
    
    @Binding var launchedInstanceProcess: InstanceProcess?
    @EnvironmentObject private var launcherData: LauncherData
    
    @State private var launchedInstances: [Instance: InstanceProcess]? = nil
    @State private var logMessages: [String] = []
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(logMessages, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                                .id(message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .id(logMessages)
                }
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 1)
                )
                .padding(.all, 7)
                
                HStack {
                    Button("open_logs_folder") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: instance.getLogsFolder().path)
                    }
                }
                .padding([.top, .leading, .trailing], 5)
                
                if let launchedInstanceProcess {
                    ZStack {
                        
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(logMessages.last, anchor: .bottom)
                        }
                        
                        logMessages = launchedInstanceProcess.logMessages
                    }
                    .onReceive(launchedInstanceProcess.$logMessages) {
                        logMessages = $0
                    }
                }
            }
            
            Spacer()
        }
    }
}
