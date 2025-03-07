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

struct InstanceView: View {
    @StateObject var instance: Instance
    @StateObject private var editingViewModel = InstanceEditingViewModel()
    @EnvironmentObject private var launcherData: LauncherData
    
    @State private var disabled = false
    @State private var starHovered = false
    @State private var logoHovered = false
    @State private var showLogoSheet = false
    @State private var showNoNamePopover = false
    @State private var showDuplicatePopover = false
    @State private var showErrorSheet = false
    @State private var showPreLaunchSheet = false
    @State private var showChooseAccountSheet = false
    @State private var launchError: LaunchError? = nil
    @State private var downloadSession: URLSession? = nil
    @State private var downloadMessage: LocalizedStringKey = "downloading_libs"
    @State private var downloadProgress = TaskProgress(current: 0, total: 1)
    @State private var progress: Float = 0
    @State private var launchedInstanceProcess: InstanceProcess? = nil
    @State private var indeterminateProgress = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    InstanceInterativeLogoView(instance: instance, showLogoSheet: $showLogoSheet, logoHovered: $logoHovered)
                    VStack {
                        HStack {
                            InstanceTitleView(editingViewModel: editingViewModel, instance: instance, showNoNamePopover: $showNoNamePopover, showDuplicatePopover: $showDuplicatePopover, starHovered: $starHovered)
                            Spacer()
                        }
                        HStack {
                            InstanceSynopsisView(editingViewModel: editingViewModel, instance: instance)
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                .sheet(isPresented: $showLogoSheet) {
                    InstanceLogoSheet(instance: instance, showLogoSheet: $showLogoSheet)
                }
                HStack {
                    InstanceNotesView(editingViewModel: editingViewModel, instance: instance)
                    Spacer()
                }
                Spacer()
                TabView {
                    InstanceConsoleView(instance: instance, launchedInstanceProcess: $launchedInstanceProcess)
                        .tabItem {
                            Label("console", systemImage: "bolt")
                        }
                    InstanceModsView(instance: instance)
                        .tabItem {
                            Label("mods", systemImage: "plus.square.on.square")
                        }
                    InstanceScreenshotsView(instance: instance)
                        .tabItem {
                            Label("screenshots", systemImage: "plus.square.on.square")
                        }
                    InstanceWorldsView(instance: instance)
                        .tabItem {
                            Label("worlds", systemImage: "plus.square.on.square")
                        }
                    InstanceRuntimeView(instance: instance)
                        .tabItem {
                            Label("runtime", systemImage: "bolt")
                        }
                }.padding(.all, 4)
            }
            .padding(.all, 6)
            .onAppear {
                launcherData.launchRequestedInstances.removeAll(where: { $0 == instance })
                launchedInstanceProcess = launcherData.launchedInstances[instance]
                instance.loadScreenshotsAsync()
            }
            .sheet(isPresented: $showErrorSheet) {
                LaunchErrorSheet(launchError: $launchError, showErrorSheet: $showErrorSheet)
            }
            .sheet(isPresented: $showPreLaunchSheet, content: createPrelaunchSheet)
            .sheet(isPresented: $showChooseAccountSheet) {
                InstanceChooseAccountSheet(showChooseAccountSheet: $showChooseAccountSheet)
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .onReceive(launcherData.$launchRequestedInstances) { value in
                if value.contains(where: { $0 == instance}) {
                    if launcherData.accountManager.currentSelected != nil {
                        showPreLaunchSheet = true
                        downloadProgress.cancelled = false
                    } else {
                        showChooseAccountSheet = true
                    }
                    
                    launcherData.launchRequestedInstances.removeAll(where: { $0 == instance })
                }
            }
            .onReceive(launcherData.$editModeInstances) { value in
                if value.contains(where: { $0 == instance}) {
                    editingViewModel.start(from: instance)
                } else if editingViewModel.inEditMode {
                    editingViewModel.commit(to: instance, showNoNamePopover: $showNoNamePopover, showDuplicateNamePopover: $showDuplicatePopover, data: launcherData)
                }
            }
            .onReceive(launcherData.$killRequestedInstances) { value in
                if value.contains(where: { $0 == instance })  {
                    kill(launchedInstanceProcess!.process.processIdentifier, SIGKILL)
                    launcherData.killRequestedInstances.removeAll(where: { $0 == instance })
                }
            }
        }
    }
    
    @ViewBuilder
    func createPrelaunchSheet() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Text(downloadMessage)
                
                Spacer()
            }
            .padding()
            
            if indeterminateProgress {
                ProgressView()
                    .progressViewStyle(.linear)
            } else {
                ProgressView(value: progress)
            }
            
            Button("abort") {
                logger.info("Aborting instance launch")
                downloadSession?.invalidateAndCancel()
                showPreLaunchSheet = false
                downloadProgress.cancelled = true
                downloadProgress = TaskProgress(current: 0, total: 1)
            }
            .onReceive(downloadProgress.$current) {
                progress = Float($0) / Float(downloadProgress.total)
            }
            .padding()
        }
        .onAppear {
            onPrelaunchSheetAppear()
        }
        .padding(.all, 10)
    }
    
    func onPrelaunchSheetAppear() {
        logger.info("Preparing to launch \(instance.name)")
        indeterminateProgress = false
        downloadProgress.cancelled = false
        downloadMessage = "downloading_libs"
        logger.info("Downloading libraries")
        
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = "downloading_assets"
            logger.info("Downloading assets")
            
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = "extracting_natives"
                logger.info("Extracting natives")
                
                downloadProgress.callback = {
                    if !downloadProgress.cancelled {
                        indeterminateProgress = true
                        downloadMessage = "authenticating_with_minecraft"
                        logger.info("Fetching access token")
                        
                        Task(priority: .high) {
                            do {
                                let accessToken = try await launcherData.accountManager.selectedAccount.createAccessToken()
                                DispatchQueue.main.async {
                                    withAnimation {
                                        let process = InstanceProcess(instance: instance, account: launcherData.accountManager.selectedAccount, accessToken: accessToken)
                                        launcherData.launchedInstances[instance] = process
                                        launchedInstanceProcess = process
                                        showPreLaunchSheet = false
                                    }
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    onPrelaunchError(.accessTokenFetchError(error: error))
                                }
                            }
                        }
                    }
                    
                    downloadProgress.callback = {}
                }
                instance.extractNatives(progress: downloadProgress)
            } onError: {
                onPrelaunchError($0)
            }
        } onError: {
            onPrelaunchError($0)
        }
    }
    
    @MainActor
    func onPrelaunchError(_ error: LaunchError) {
        if showErrorSheet {
            logger.debug("Suppressed error during prelaunch: \(error.localizedDescription)")
            
            if let sup = error.cause {
                logger.debug("Cause: \(sup.localizedDescription)")
            }
            
            return
        }
        
        logger.error("Caught error during prelaunch", error: error)
        ErrorTracker.instance.error(error: error, description: "Caught error during prelaunch")
        
        if let cause = error.cause {
            logger.error("Cause", error: cause)
            ErrorTracker.instance.error(error: error, description: "Causative error during prelaunch")
        }
        
        showPreLaunchSheet = false
        showErrorSheet = true
        downloadProgress.cancelled = true
        launchError = error
    }
}
