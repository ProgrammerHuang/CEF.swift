//
//  CEFRequest.swift
//  cef
//
//  Created by Tamas Lustyik on 2015. 07. 12..
//
//

import Foundation

public extension CEFRequest {
    public typealias HeaderMap = [String: [String]]
    
    /// Create a new CefRequest object.
    public convenience init?() {
        self.init(ptr: cef_request_create())
    }
    
    /// Returns true if this object is read-only.
    public var isReadOnly: Bool {
        return cefObject.is_read_only(cefObjectPtr) != 0
    }
    
    /// Fully qualified URL.
    public var url: NSURL {
        get { return getURL() }
        set { setURL(newValue) }
    }
    
    /// Get the fully qualified URL.
    private func getURL() -> NSURL {
        let cefURLPtr = cefObject.get_url(cefObjectPtr)
        defer { CEFStringPtrRelease(cefURLPtr) }
        let urlStr = CEFStringToSwiftString(cefURLPtr.memory)
        
        return NSURL(string: urlStr)!
    }
    
    /// Set the fully qualified URL.
    private func setURL(url: NSURL) {
        let cefURLPtr = CEFStringPtrCreateFromSwiftString(url.absoluteString)
        defer { CEFStringPtrRelease(cefURLPtr) }
        cefObject.set_url(cefObjectPtr, cefURLPtr)
    }
    
    /// Request method type. The value will default to POST if post data
    /// is provided and GET otherwise.
    public var method: String {
        get { return getMethod() }
        set { setMethod(newValue) }
    }
    
    /// Get the request method type. The value will default to POST if post data
    /// is provided and GET otherwise.
    private func getMethod() -> String {
        let cefMethodPtr = cefObject.get_method(cefObjectPtr)
        defer { CEFStringPtrRelease(cefMethodPtr) }
        return CEFStringToSwiftString(cefMethodPtr.memory)
    }
    
    /// Set the request method type.
    private func setMethod(method: String) {
        let cefMethodPtr = CEFStringPtrCreateFromSwiftString(method)
        defer { CEFStringPtrRelease(cefMethodPtr) }
        cefObject.set_method(cefObjectPtr, cefMethodPtr)
    }
    
    /// Get the post data.
    public var postData: CEFPOSTData? {
        get {
            let cefPOSTDataPtr = cefObject.get_post_data(cefObjectPtr)
            return CEFPOSTData.fromCEF(cefPOSTDataPtr)
        }
        set { cefObject.set_post_data(cefObjectPtr, newValue != nil ? newValue!.toCEF() : nil) }
    }
    
    /// Header values
    public var headers: HeaderMap {
        get { return getHeaderMap() }
        set { setHeaderMap(newValue) }
    }
    
    /// Get the header values.
    private func getHeaderMap() -> HeaderMap {
        let cefHeaderMap = cef_string_multimap_alloc()
        defer { cef_string_multimap_free(cefHeaderMap) }
        cefObject.get_header_map(cefObjectPtr, cefHeaderMap)
        return CEFStringMultimapToSwiftDictionaryOfArrays(cefHeaderMap)
    }
    
    /// Set the header values.
    private func setHeaderMap(headerMap: HeaderMap) {
        let cefHeaderMap = CEFStringMultimapCreateFromSwiftDictionaryOfArrays(headerMap)
        defer { cef_string_multimap_free(cefHeaderMap) }
        cefObject.set_header_map(cefObjectPtr, cefHeaderMap)
    }
    
    /// Set all values at one time.
    public func set(url: NSURL, method: String, postData: CEFPOSTData? = nil, headers: HeaderMap) {
        let cefURLPtr = CEFStringPtrCreateFromSwiftString(url.absoluteString)
        let cefMethodPtr = CEFStringPtrCreateFromSwiftString(method)
        let cefHeaderMap = CEFStringMultimapCreateFromSwiftDictionaryOfArrays(headers)
        let cefData = postData != nil ? postData!.toCEF() : nil
        defer {
            CEFStringPtrRelease(cefURLPtr)
            CEFStringPtrRelease(cefMethodPtr)
            cef_string_multimap_free(cefHeaderMap)
        }
        
        cefObject.set(cefObjectPtr, cefURLPtr, cefMethodPtr, cefData, cefHeaderMap)
    }
    
    /// The flags used in combination with CefURLRequest. See
    /// cef_urlrequest_flags_t for supported values.
    public var flags: CEFURLRequestFlags {
        get {
            let cefFlags = cefObject.get_flags(cefObjectPtr)
            return CEFURLRequestFlags(rawValue: UInt32(cefFlags))
        }
        set { cefObject.set_flags(cefObjectPtr, Int32(flags.rawValue)) }
    }

    /// The URL to the first party for cookies used in combination with
    /// CefURLRequest.
    public var firstPartyURLForCookies: NSURL {
        get { return getFirstPartyForCookies() }
        set { setFirstPartyForCookies(newValue) }
    }

    /// Set the URL to the first party for cookies used in combination with
    /// CefURLRequest.
    private func getFirstPartyForCookies() -> NSURL {
        let cefURL = cefObject.get_first_party_for_cookies(cefObjectPtr)
        defer { CEFStringPtrRelease(cefURL) }

        let urlStr = CEFStringToSwiftString(cefURL.memory)
        return NSURL(string: urlStr)!
    }
    
    /// Get the URL to the first party for cookies used in combination with
    /// CefURLRequest.
    private func setFirstPartyForCookies(url: NSURL) {
        let cefURLPtr = CEFStringPtrCreateFromSwiftString(url.absoluteString)
        defer { CEFStringPtrRelease(cefURLPtr) }
        cefObject.set_first_party_for_cookies(cefObjectPtr, cefURLPtr)
    }
    
    /// Get the resource type for this request. Only available in the browser
    /// process.
    public var resourceType: CEFResourceType {
        let cefRT = cefObject.get_resource_type(cefObjectPtr)
        return CEFResourceType.fromCEF(cefRT)
    }
    
    /// Get the transition type for this request. Only available in the browser
    /// process and only applies to requests that represent a main frame or
    /// sub-frame navigation.
    public var transitionType: CEFTransitionType {
        let cefTT = cefObject.get_transition_type(cefObjectPtr)
        return CEFTransitionType.fromCEF(cefTT)
    }
    
    /// Returns the globally unique identifier for this request or 0 if not
    /// specified. Can be used by CefRequestHandler implementations in the browser
    /// process to track a single request across multiple callbacks.
    public var identifier: UInt64? {
        let cefID = cefObject.get_identifier(cefObjectPtr)
        return cefID != 0 ? cefID : nil
    }

}

