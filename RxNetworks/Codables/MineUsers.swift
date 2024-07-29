//
//  MineUsers.swift
//  RxNetworks_Example
//
//  Created by Condy on 2024/7/28.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import HollowCodable

struct MineUsers: HollowCodable {
    var login: String? //": "yangKJ",
    var userId: Int? //": 17396101,
    var node_id: String? //": "MDQ6VXNlcjE3Mzk2MTAx",
    var avatar_url: URL? //": "https://avatars.githubusercontent.com/u/17396101?v=4",
    var gravatar_id: String? //": "",
    var url: String? //": "https://api.github.com/users/yangKJ",
    var html_url: String? //": "https://github.com/yangKJ",
    var followers_url: String? //": "https://api.github.com/users/yangKJ/followers",
    var following_url: String? //": "https://api.github.com/users/yangKJ/following{/other_user}",
    var gists_url: String? //": "https://api.github.com/users/yangKJ/gists{/gist_id}",
    var starred_url: String? //": "https://api.github.com/users/yangKJ/starred{/owner}{/repo}",
    var subscriptions_url: String? //": "https://api.github.com/users/yangKJ/subscriptions",
    var organizations_url: String? //": "https://api.github.com/users/yangKJ/orgs",
    var repos_url: String? //": "https://api.github.com/users/yangKJ/repos",
    var events_url: String? //": "https://api.github.com/users/yangKJ/events{/privacy}",
    var received_events_url: String? //": "https://api.github.com/users/yangKJ/received_events",
    var type: String? //": "User",
    var site_admin: Bool? //": false,
    var name: String? //": "Condy",
    var company: String? //": "None",
    var blog: String? //": "https://github.com/yangKJ",
    var location: String? //": "Chengdu",
    var email: String? //": null,
    var hireable: Bool? //": true,
    var bio: String? //": "🧸 A drummer is also an ios engineer and loves rock music.",
    var twitter_username: String? //": null,
    var public_repos: Int? //": 46,
    var public_gists: Int? //": 0,
    var followers: Int? //": 269,
    var following: Int? //": 1,
    var createdAt: Date? //": "2016-02-22T01:51:01Z",
    var updatedAt: Date? //": "2023-05-28T11:40:39Z"
    
    static func mapping(mapper: HelpingMapper) {
        mapper <<< CodingKeys.userId <-- ["userID", "id"]
        mapper <<< CodingKeys.createdAt <-- "created_at"
        mapper <<< CodingKeys.updatedAt <-- "updated_at"
        mapper <<< CodingKeys.createdAt <-- RFC3339DateTransform()
        mapper <<< CodingKeys.updatedAt <-- RFC3339DateTransform()
    }
}
