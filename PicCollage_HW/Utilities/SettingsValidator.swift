//
//  SettingsValidator.swift
//  PicCollage_HW
//
//  Created by Claude Code on 2025/11/5.
//

import Foundation
import CoreGraphics

struct SettingsValidator {
    // MARK: - Constants
    enum ValidationConstants {
        static let minTotalDuration: CGFloat = 0
        static let minPercentage: CGFloat = 0
        static let maxPercentage: CGFloat = 100
    }

    // MARK: - Validation Errors
    enum ValidationError: LocalizedError {
        case invalidTotalDuration
        case invalidKeyTimePercentage
        case invalidTimelinePercentage
        case emptyKeyTimeField

        var errorDescription: String? {
            switch self {
            case .invalidTotalDuration:
                return "Please enter a valid total track length (must be > 0)"
            case .invalidKeyTimePercentage:
                return "KeyTime percentages must be between 0 and 100"
            case .invalidTimelinePercentage:
                return "Timeline length percentage must be between 0 and 100"
            case .emptyKeyTimeField:
                return "KeyTime field cannot be empty"
            }
        }
    }

    // MARK: - Validation Methods
    static func validateTotalDuration(_ duration: CGFloat?) throws {
        guard let duration = duration, duration > ValidationConstants.minTotalDuration else {
            throw ValidationError.invalidTotalDuration
        }
    }

    static func validatePercentage(_ percentage: CGFloat?, allowEmpty: Bool = false) throws {
        if allowEmpty && percentage == nil {
            return
        }

        guard let percentage = percentage else {
            throw ValidationError.emptyKeyTimeField
        }

        guard percentage >= ValidationConstants.minPercentage && percentage <= ValidationConstants.maxPercentage else {
            throw ValidationError.invalidKeyTimePercentage
        }
    }

    static func validateTimelinePercentage(_ percentage: CGFloat?) throws {
        guard let percentage = percentage else {
            return // Timeline is optional
        }

        guard percentage > ValidationConstants.minPercentage && percentage <= ValidationConstants.maxPercentage else {
            throw ValidationError.invalidTimelinePercentage
        }
    }
}
