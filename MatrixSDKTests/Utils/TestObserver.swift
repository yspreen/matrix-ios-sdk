// 
// Copyright 2021 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

import XCTest

/// TestObserver offers additional checks on tests
@objcMembers
class TestObserver: NSObject {
    static let shared = TestObserver()
    
    var initialised: Bool = false
    
    /// Launch the tracking on open MXSessions
    /// There will be `fatalError()` if there are still open MXSession at the end of a test
    func trackMXSessions() {
        if !initialised {
            MXSession.trackOpenMXSessions()
            XCTestObservationCenter.shared.addTestObserver(self)
            initialised = true
        }
    }
}

extension TestObserver: XCTestObservation {
    func testCaseDidFinish(_ testCase: XCTestCase) {
        // Crash in caa
        let count = MXSession.openMXSessionsCount
        if count > 0 {
            MXSession.logOpenMXSessions()
            
            // All MXSessions must be closed at the end of the test
            // Else, they will continue to run in background and affect tests performance
            fatalError("Test \(testCase.name) did not close \(count) MXSession instances")
        }
    }
}
