//
//  EvurlRequestWithCellularData.swift
//
//  Created by BENJAMIN BRYANT BUDIMAN on 05/09/18.
//  Copyright © 2021 Boku, Inc. All rights reserved.
//

import Foundation

/**
Requests the EvURL with cellular data, and checks whether the PNV process completes or not.
Important note: this funciton shall always return false if cellular data is not available.

 - Parameter evurl: The EvURL to be requested
 - Returns: true if the PNV process is successful and vice versa
 */
func requestEvurlWithCellularData(evurl:String) -> Bool {
    let response = requestHelper(url: evurl)
    
    // If any internal and network errors occured in HTTPRequester.performGetRequest, the function will return "ERROR"
    if response == "ERROR" {
        return false;
    }
    
    // Boku returns "ErrorCode=0&ErrorDescription=Success" only when the PNV process is complete
    if response.range(of:"ErrorCode=0&ErrorDescription=Success") != nil {
        return true;
    }
    
    // Any HTTP responses without the above substring indicate an incomplete PNV process
    return false;
}

/**
 Recursive function that keeps requesting a new URL with cellular data when the HTTP request returns a HTTP redirect code (3xx)
 
 - Parameter url: The URL to be requested
 - Returns: string response from the HTTP request
 */
func requestHelper(url:String) -> String {
    // If the HTTP GET request returns a HTTP redirect code (3xx), HTTPRequester.performGetRequest returns a
    // formatted string that contains the redirect URL. The formatted string starts with "REDIRECT:"
    // and it's followed with the redirect URL (e.g. REDIRECT:https://www.boku.com)
    var response = HTTPRequester.performGetRequest(URL(string: url))
    
    if response!.range(of:"REDIRECT:") != nil {
        // 1. Get the redirect URL by getting rid of the "REDIRECT:" substring
        let redirectRange = response!.index(response!.startIndex, offsetBy: 9)...
        let redirectLink = String(response![redirectRange])
        
        // 2. Make a request to the redirect URL
        response = requestHelper(url: redirectLink)
    }
    
    return response!
}
