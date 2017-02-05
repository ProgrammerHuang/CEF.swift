//
//  CEFCrashUtils.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2017. 02. 05..
//  Copyright © 2017. Tamas Lustyik. All rights reserved.
//

import Foundation

/// Crash reporting is configured using an INI-style config file named
/// "crash_reporter.cfg". On Windows and Linux this file must be placed next to
/// the main application executable. On macOS this file must be placed in the
/// top-level app bundle Resources directory (e.g.
/// "<appname>.app/Contents/Resources"). File contents are as follows:
///
///  # Comments start with a hash character and must be on their own line.
///
///  [Config]
///  ProductName=<Value of the "prod" crash key; defaults to "cef">
///  ProductVersion=<Value of the "ver" crash key; defaults to the CEF version>
///  AppName=<Windows only; App-specific folder name component for storing crash
///           information; default to "CEF">
///  ExternalHandler=<Windows only; Name of the external handler exe to use
///                   instead of re-launching the main exe; default to empty>
///  ServerURL=<crash server URL; default to empty>
///  RateLimitEnabled=<True if uploads should be rate limited; default to true>
///  MaxUploadsPerDay=<Max uploads per 24 hours, used if rate limit is enabled;
///                    default to 5>
///  MaxDatabaseSizeInMb=<Total crash report disk usage greater than this value
///                       will cause older reports to be deleted; default to 20>
///  MaxDatabaseAgeInDays=<Crash reports older than this value will be deleted;
///                        default to 5>
///
///  [CrashKeys]
///  my_key1=<small|medium|large>
///  my_key2=<small|medium|large>
///
/// Config section:
///
/// If "ProductName" and/or "ProductVersion" are set then the specified values
/// will be included in the crash dump metadata. On macOS if these values are set
/// to empty then they will be retrieved from the Info.plist file using the
/// "CFBundleName" and "CFBundleShortVersionString" keys respectively.
///
/// If "AppName" is set on Windows then crash report information (metrics,
/// database and dumps) will be stored locally on disk under the
/// "C:\Users\[CurrentUser]\AppData\Local\[AppName]\User Data" folder. On other
/// platforms the CefSettings.user_data_path value will be used.
///
/// If "ExternalHandler" is set on Windows then the specified exe will be
/// launched as the crashpad-handler instead of re-launching the main process
/// exe. The value can be an absolute path or a path relative to the main exe
/// directory. On Linux the CefSettings.browser_subprocess_path value will be
/// used. On macOS the existing subprocess app bundle will be used.
///
/// If "ServerURL" is set then crashes will be uploaded as a multi-part POST
/// request to the specified URL. Otherwise, reports will only be stored locally
/// on disk.
///
/// If "RateLimitEnabled" is set to true then crash report uploads will be rate
/// limited as follows:
///  1. If "MaxUploadsPerDay" is set to a positive value then at most the
///     specified number of crashes will be uploaded in each 24 hour period.
///  2. If crash upload fails due to a network or server error then an
///     incremental backoff delay up to a maximum of 24 hours will be applied for
///     retries.
///  3. If a backoff delay is applied and "MaxUploadsPerDay" is > 1 then the
///     "MaxUploadsPerDay" value will be reduced to 1 until the client is
///     restarted. This helps to avoid an upload flood when the network or
///     server error is resolved.
/// Rate limiting is not supported on Linux.
///
/// If "MaxDatabaseSizeInMb" is set to a positive value then crash report storage
/// on disk will be limited to that size in megabytes. For example, on Windows
/// each dump is about 600KB so a "MaxDatabaseSizeInMb" value of 20 equates to
/// about 34 crash reports stored on disk. Not supported on Linux.
///
/// If "MaxDatabaseAgeInDays" is set to a positive value then crash reports older
/// than the specified age in days will be deleted. Not supported on Linux.
///
/// CrashKeys section:
///
/// Any number of crash keys can be specified for use by the application. Crash
/// key values will be truncated based on the specified size (small = 63 bytes,
/// medium = 252 bytes, large = 1008 bytes). The value of crash keys can be set
/// from any thread or process using the CefSetCrashKeyValue function. These
/// key/value pairs will be sent to the crash server along with the crash dump
/// file. Medium and large values will be chunked for submission. For example,
/// if your key is named "mykey" then the value will be broken into ordered
/// chunks and submitted using keys named "mykey-1", "mykey-2", etc.
public struct CEFCrashUtils {
    
    /// Returns whether CEF's own crash reporting is enabled
    /// CEF name: `CefCrashReportingEnabled`
    static var isReportingEnabled: Bool {
        return cef_crash_reporting_enabled() != 0
    }
    
    /// Sets or clears a specific key-value pair from the crash metadata.
    /// CEF name: `CefSetCrashKeyValue`
    static func setValue(_ value: String?, forKey key: String) {
        let cefKeyPtr = CEFStringPtrCreateFromSwiftString(key)
        let cefValuePtr = value != nil ? CEFStringPtrCreateFromSwiftString(value!) : nil
        defer {
            CEFStringPtrRelease(cefKeyPtr)
            CEFStringPtrRelease(cefValuePtr)
        }
        
        cef_set_crash_key_value(cefKeyPtr, cefValuePtr)
    }
    
}