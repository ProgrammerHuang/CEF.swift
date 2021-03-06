//
//  CEFDraggableRegion.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2015. 08. 11..
//  Copyright © 2015. Tamas Lustyik. All rights reserved.
//

import Foundation

/// Structure representing a draggable region.
public struct CEFDraggableRegion {
    /// Bounds of the region.
    public let bounds: NSRect

    /// True (1) this this region is draggable and false (0) otherwise.
    public let isDraggable: Bool
}

extension CEFDraggableRegion {
    static func fromCEF(value: cef_draggable_region_t) -> CEFDraggableRegion {
        return CEFDraggableRegion(bounds: NSRect.fromCEF(value.bounds),
                                  isDraggable: value.draggable != 0)
    }
}

