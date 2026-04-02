"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.del = exports.set = exports.get = void 0;
// Minimal cache service implementation
const get = async (key) => {
    return null;
};
exports.get = get;
const set = async (key, value, ttl) => {
    return true;
};
exports.set = set;
const del = async (key) => {
    return true;
};
exports.del = del;
