//
//  SafariExtensionHandler.swift
//  sVimPort Extension
//
//  Created by Donald Lieu on 8/15/19.
//  Copyright © 2019 Donald Lieu. All rights reserved.
//

import SafariServices

enum ActionType: String {
    case sendSettings
    case openLinkInTab
    case openNewTab
    case nextTab
    case backTab
    case closeTab
}

struct settings {
    let vimariValues: [String: Any] = [
        "modifier": "",
        "excludedUrls": "",
        "hintToggle": "f",
        "newTabHintToggle": "shift+f",
        "linkHintCharacters": "asdfjklqwerzxc",
        "detectByCursorStyle": false,
        
        "scrollUp": "k",
        "scrollDown": "j",
        "scrollLeft": "h",
        "scrollRight": "l",
        "scrollSize": 75,
        "scrollUpHalfPage": "e",
        "scrollDownHalfPage": "d",
        "goToPageTop": "g g",
        "goToPageBottom": "shift+g",
        
        "goBack": "shift+h",
        "goForward": "shift+l",
        "reload": "r",
        "tabForward": "shift+k",
        "tabBack": "shift+j",
        "closeTab": "x",
        "closeTabReverse": "shift+x",
        
        "openTab": "t",
    ]
    let sVimValues: [String: Any] = [
        "preventdefaultesc" : true,
        "smoothscroll" : true,
        "fullpagescrollpercent" : 85,
        "lastactivetablimit"    : 25,
        "lastclosedtablimit"    : 25,
        "scrollduration"        : 30,
        "scrollstep"            : 60,
        "zoomstep"              : 10,
        "barposition"           : "bottom",
        "hintcharacters"        : "asdfgqwertzxcvb",
        "homeurl"               : "topsites://",
        "mapleader"             : "\\",
        "newtaburl"             : "topsites://",
        "blacklists"            : [],
        "nextpagetextpatterns"  : ["(Next)(\\s>)?"],
        "prevpagetextpatterns"  : ["Prev(ious)?"],
        "sitepagination"        : [
            "*://*.ebay.com/*"      : [
                "next": "[aria-label='Go to next search page']",
                "prev": "[aria-label='Go to previous search page']"
            ],
            "*://mail.google.com/*": [
                "next": "[aria-label='Newer']",
                "prev": "[aria-label='Older']"
            ],
            "*://*.reddit.com/*": [
                "next": "a[rel$='next']",
                "prev": "a[rel$='prev']"
            ]
        ],
        "shortcuts"             : [
            // why are theys values backwards?
            "j"             : "scrollDown",
            "k"             : "scrollUp",
            "h"             : "scrollLeft",
            "l"             : "scrollRight",
            "d"             : "scrollPageDown",
            "e"             : "scrollPageUp",
            "u"             : "scrollPageUp",
            "shift+d"       : "scrollFullPageDown",
            "shift+e"       : "scrollFullPageUp",
            "shift+g"       : "scrollToBottom",
            "g g"           : "scrollToTop",
            "0"             : "scrollToLeft",
            "$"             : "scrollToRight",
            "g i"           : "goToInput",
            "g n"           : "gotoNextPage",
            "g p"           : "gotoPrevPage",
            // Miscellaneous
            "r"             : "reloadTab",
            "z i"           : "zoomPageIn",
            "z o"           : "zoomPageOut",
            "z 0"           : "zoomOrig",
            "g r"           : "toggleReader",
            "g v"           : "showsVimrc",
            "g ?"           : "help",
            // Tab Navigation
            "g t"           : "nextTab",
            "shift+k"       : "nextTab",
            "g shift+t"     : "previousTab",
            "shift+j"       : "previousTab",
            "g 0"           : "firstTab",
            "g $"           : "lastTab",
            "g l"           : "lastActiveTab",
            "x"             : "quit",
            "g x shift+t"   : "closeTabLeft",
            "g x t"         : "closeTabRight",
            "g x 0"         : "closeTabsToLeft",
            "g x $"         : "closeTabsToRight",
            "g x o"         : "closeOtherTabs",
            "shift+x"       : "lastClosedTab",
            "ctrl+shift+x"  : "lastClosedTabBackground",
            "t"             : "newTab",
            "shift+h"       : "goBack",
            "shift+l"       : "goForward",
            "shift+,"       : "moveTabLeft",
            "shift+."       : "moveTabRight",
            "g u"           : "parentDirectory",
            "g shift+u"     : "topDirectory",
            "g d"           : "parentDomain",
            "g h"           : "homePage",
            // Window Navigation
            "w"             : "newWindow",
            "g w"           : "nextWindow",
            "g shift+w"     : "previousWindow",
            // Modes
            "escape"        : "normalMode",
            "ctrl+["        : "normalMode",
            "i"             : "insertMode",
            // Link Hints
            "f"             : "createHint",
            "shift+f"       : "createTabbedHint",
            "ctrl+shift+f"  : "createForegroundHint",
            // Clipboard
            "y y"            : "yankDocumentUrl"
        ]
    ]
}

let settings_object = settings()

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        switch messageName {
        case ActionType.sendSettings.rawValue:
            page.dispatchMessageToScript(withName: "settings", userInfo: settings_object.sVimValues)
            break
        case ActionType.openLinkInTab.rawValue:
            let url = URL(string: userInfo?["url"] as! String)
            openInNewTab(url: url!)
            break
        case ActionType.openNewTab.rawValue:
            openNewTab()
            break
        case ActionType.nextTab.rawValue:
            changeTab(direction: "forward")
            break
        case ActionType.backTab.rawValue:
            changeTab(direction: "backward")
            break
        case ActionType.closeTab.rawValue:
            closeTab()
            break
        default:
            NSLog("Received message with unsupported type: \(messageName)")
        }
    }
    
    func openInNewTab(url: URL) {
        SFSafariApplication.getActiveWindow(completionHandler: {
            $0?.openTab(with: url, makeActiveIfPossible: false, completionHandler: {_ in
                // Perform some action here after the page loads
            })
        })
    }
    
    func openNewTab() {
        // Ideally this URL would be something that represents an empty tab better than localhost
        SFSafariExtension.getBaseURI { baseURI in
            let url = baseURI?.appendingPathComponent("sVimrc.html")
            SFSafariApplication.getActiveWindow(completionHandler: {
                $0?.openTab(with: url!, makeActiveIfPossible: true, completionHandler: {_ in
                    // Perform some action here after the page loads
                })
            })
        }
        //let url = URL(string: "https://online.bonjourr.fr")!
        
    }
    
    func changeTab(direction :String) {
        let forward : Int
        if direction == "forward" {
            forward = 1
        } else {
            forward = -1
        }
        SFSafariApplication.getActiveWindow { (window) in
            window?.getActiveTab {
                (current_tab) in
                window?.getAllTabs {
                    (tabs) in
                    for (index, tab) in tabs.enumerated() {
                        if current_tab == tab {
                            tabs[(((index + forward) % tabs.count) + tabs.count) % tabs.count].activate(completionHandler: {})
                        }
                    }
                }
            }
        }
    }
    
    func closeTab() {
        SFSafariApplication.getActiveWindow(completionHandler: {
            (window) in
            window?.getActiveTab(completionHandler: {
                (tab) in
                tab?.close()
            })
        })
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
