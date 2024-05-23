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

import Foundation

public class ArgumentProvider {
    public var values: [String: String] = [:]
    
    public init() {
        
    }
    
    public func accept(_ str: [String]) -> [String] {
        var visited: [String] = []
        
        for component in str {
            if component[component.startIndex] != "$" {
                visited.append(component)
                continue
            }
            
            let variable = String(component.dropFirst(2).dropLast())
            
            if let value = values[variable] {
                visited.append(value)
            }
        }
        
        return visited
    }
    
    public func clientId(_ clientId: String) {
        values["clientId"] = clientId
    }
    
    public func xuid(_ xuid: String) {
        values["auth_xuid"] = xuid
    }
    
    public func username(_ username: String) {
        values["auth_player_name"] = username
    }
    
    public func version(_ version: String) {
        values["version_name"] = version
        values["version"] = version
    }
    
    public func gameDir(_ gameDir: URL) {
        values["game_directory"] = gameDir.path
    }
    
    public func assetsDir(_ assetsDir: URL) {
        values["assets_root"] = assetsDir.path
        values["game_assets"] = assetsDir.path
    }
    
    public func assetIndex(_ assetIndex: String) {
        values["assets_index_name"] = assetIndex
    }
    
    public func nativesDir(_ directory: String) {
        values["natives_directory"] = directory
    }
    
    public func uuid(_ uuid: UUID) {
        values["auth_uuid"] = uuid.uuidString
        values["uuid"] = uuid.uuidString
    }
    
    public func accessToken(_ accessToken: String) {
        values["auth_access_token"] = accessToken
        values["auth_session"] = accessToken
        values["accessToken"] = accessToken
    }
    
    public func userType(_ userType: String) {
        values["user_type"] = userType
    }
    
    public func versionType(_ versionType: String) {
        values["version_type"] = versionType
    }
    
    public func width(_ width: Int) {
        values["resolution_width"] = String(width)
    }
    
    public func height(_ height: Int) {
        values["resolution_height"] = String(height)
    }
}
