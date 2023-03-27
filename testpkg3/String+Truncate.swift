//
//  String+Truncate.swift
//  testpkg3
//
//  Created by Tianbo Qiu on 3/27/23.
//

import Foundation

extension String {
    func truncatePrefix(_ maxLength: Int, using truncator: String = "...") -> String {
        "\(prefix(maxLength))\(truncator)"
    }
}
