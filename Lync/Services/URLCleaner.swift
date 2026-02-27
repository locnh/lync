import Foundation

// Strips common tracking / analytics query parameters from URLs before opening
final class URLCleaner {
    static let shared = URLCleaner()
    private init() {}

    // Well-known tracking parameters from UTM, Facebook, Google, HubSpot, etc.
    private let trackingParams: Set<String> = [
        // UTM (Google Analytics / general)
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "utm_id",
        "utm_reader", "utm_place", "utm_name",
        // Facebook
        "fbclid", "fb_action_ids", "fb_action_types", "fb_ref", "fb_source", "fb_jscode",
        // Google Ads
        "gclid", "gclsrc", "gbraid", "wbraid", "dclid",
        // Microsoft Ads
        "msclkid",
        // HubSpot
        "hsa_acc", "hsa_cam", "hsa_grp", "hsa_ad", "hsa_src",
        "hsa_tgt", "hsa_kw", "hsa_mt", "hsa_net", "hsa_ver",
        // Mailchimp
        "mc_cid", "mc_eid",
        // Marketo
        "mkt_tok",
        // Pinterest
        "epik",
        // TikTok
        "ttclid",
        // Twitter / X
        "twclid",
        // Misc referral / affiliate
        "ref", "referer", "referrer", "source",
        "affiliate_id", "affiliate", "aff_id",
        // IRClickID (Impact)
        "irclickid",
        // Outbrain
        "obOrigUrl",
        // Yandex
        "yclid",
    ]

    // Returns the URL with all recognised tracking parameters removed.
    // Query items with other names are preserved unchanged.
    func clean(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let items = components.queryItems,
              !items.isEmpty else {
            return url
        }

        let cleaned = items.filter { item in
            !trackingParams.contains(item.name.lowercased())
        }

        components.queryItems = cleaned.isEmpty ? nil : cleaned
        return components.url ?? url
    }
}
