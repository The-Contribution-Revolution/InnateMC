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

public enum LaunchError: Error {
    case errorDownloading(error: Error?),
         invalidShaHash(error: Error?),
         unknownError(error: Error?),
         accessTokenFetchError(error: Error?),
         errorCreatingFile(error: Error?)
    
    var cause: Error? {
        switch(self) {
        case .errorDownloading(let error),
                .invalidShaHash(let error),
                .unknownError(let error),
                .accessTokenFetchError(let error),
                .errorCreatingFile(let error):
            return error
        }
    }
    
    var localizedDescription: String {
        switch(self) {
        case .errorDownloading(_):
            NSLocalizedString("error_downloading", comment: "no u")
            
        case .invalidShaHash(_):
            NSLocalizedString("invalid_sha_hash_error", comment: "no u")
            
        case .unknownError(_):
            NSLocalizedString("error_unknown_download", comment: "no u")
            
        case .accessTokenFetchError(_):
            NSLocalizedString("error_fetching_access_token", comment: "no u")
            
        case .errorCreatingFile(_):
            NSLocalizedString("error_creating_file", comment: "no u")
        }
    }
}
