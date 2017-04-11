//
//  AKKorgLowPassFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKKorgLowPassFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKKorgLowPassFilter(input)
        input.start()
        AKTestMD5("60784c8de74c0ce230d4eb460dbd3904")
    }
}
