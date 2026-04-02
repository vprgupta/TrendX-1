"use strict";
/**
 * tiktokService.ts
 *
 * TikTok does not offer a public API or scrapable trending page.
 * tokboard.com (previously used) no longer exists.
 *
 * Returning empty array so the scheduler does not waste time or
 * produce error noise. TikTok trends will be excluded until an
 * official API or valid third-party source becomes available.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTikTokTrends = void 0;
const getTikTokTrends = async () => {
    return [];
};
exports.getTikTokTrends = getTikTokTrends;
