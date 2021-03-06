//
//  CEFPrintHandler.g.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2015. 08. 16..
//  Copyright © 2015. Tamas Lustyik. All rights reserved.
//

import Foundation

func CEFPrintHandler_on_print_settings(ptr: UnsafeMutablePointer<cef_print_handler_t>,
                                       settings: UnsafeMutablePointer<cef_print_settings_t>,
                                       getDefaults: Int32) {
    guard let obj = CEFPrintHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onPrintSettings(CEFPrintSettings.fromCEF(settings)!, defaults: getDefaults != 0)
}

func CEFPrintHandler_on_print_dialog(ptr: UnsafeMutablePointer<cef_print_handler_t>,
                                     hasSelection: Int32,
    callback: UnsafeMutablePointer<cef_print_dialog_callback_t>) -> Int32 {
    guard let obj = CEFPrintHandlerMarshaller.get(ptr) else {
        return 0
    }
    
    return obj.onPrintDialog(hasSelection != 0, callback: CEFPrintDialogCallback.fromCEF(callback)!) ? 1 : 0
}

func CEFPrintHandler_on_print_job(ptr: UnsafeMutablePointer<cef_print_handler_t>,
                                  name: UnsafePointer<cef_string_t>,
    pdfPath: UnsafePointer<cef_string_t>,
    callback: UnsafeMutablePointer<cef_print_job_callback_t>) -> Int32 {
    guard let obj = CEFPrintHandlerMarshaller.get(ptr) else {
        return 0
    }
    
    return obj.onPrintJob(CEFStringToSwiftString(name.memory),
                          pdfFilePath: CEFStringToSwiftString(pdfPath.memory),
                          callback: CEFPrintJobCallback.fromCEF(callback)!) ? 1 : 0
}

func CEFPrintHandler_on_print_reset(ptr: UnsafeMutablePointer<cef_print_handler_t>) {
    guard let obj = CEFPrintHandlerMarshaller.get(ptr) else {
        return
    }
    
    obj.onPrintReset()
}

