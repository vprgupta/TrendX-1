"use strict";
/**
 * instagramService.ts
 *
 * Instagram does not offer a public trending API.
 * hashtagify.me (previously used) blocks automated requests (timeout/403).
 *
 * Returning empty array so the scheduler does not waste time or
 * produce error noise. Instagram trends will be excluded until an
 * official API or valid third-party source becomes available.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getInstagramTrends = void 0;
const getInstagramTrends = async () => {
    return [];
};
exports.getInstagramTrends = getInstagramTrends;
