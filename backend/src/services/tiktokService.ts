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

export const getTikTokTrends = async (): Promise<any[]> => {
    return [];
};
