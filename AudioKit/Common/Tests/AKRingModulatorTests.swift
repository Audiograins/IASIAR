//
//  AKRingModulatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKRingModulatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKRingModulator(input)
        input.start()
        AKTestMD5("4cd72c9b6398a8b7dcd1f5e7966c66f2", alternate: "b8c2dbcb323e4b2cfa21207830f45a40")
    }
}
