"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var axios_1 = require("axios");
var BASE_URL = 'http://localhost:3000/api';
function verifyEndpoints() {
    return __awaiter(this, void 0, void 0, function () {
        var overview, sentiment, topTrends, chart, integrations, userStats, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    console.log('🔍 Verifying Dashboard API Endpoints...');
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 8, , 9]);
                    // 1. Verify Analytics Overview
                    console.log('\nTesting /analytics/overview...');
                    return [4 /*yield*/, axios_1.default.get("".concat(BASE_URL, "/analytics/overview"))];
                case 2:
                    overview = _a.sent();
                    console.log('✅ Overview Data:', overview.data);
                    // 2. Verify Sentiment Analysis
                    console.log('\nTesting /analytics/sentiment...');
                    return [4 /*yield*/, axios_1.default.get("".concat(BASE_URL, "/analytics/sentiment"))];
                case 3:
                    sentiment = _a.sent();
                    console.log('✅ Sentiment Data:', sentiment.data);
                    // 3. Verify Top Trends
                    console.log('\nTesting /analytics/top-trends...');
                    return [4 /*yield*/, axios_1.default.get("".concat(BASE_URL, "/analytics/top-trends"))];
                case 4:
                    topTrends = _a.sent();
                    console.log("\u2705 Top Trends: Found ".concat(topTrends.data.length, " trends"));
                    // 4. Verify Chart Data
                    console.log('\nTesting /analytics/chart...');
                    return [4 /*yield*/, axios_1.default.get("".concat(BASE_URL, "/analytics/chart"))];
                case 5:
                    chart = _a.sent();
                    console.log("\u2705 Chart Data: Found ".concat(chart.data.length, " data points"));
                    // 5. Verify Integration Status
                    console.log('\nTesting /integrations/status...');
                    return [4 /*yield*/, axios_1.default.get("".concat(BASE_URL, "/integrations/status"))];
                case 6:
                    integrations = _a.sent();
                    console.log('✅ Integration Status:', integrations.data);
                    // 6. Verify User Stats
                    console.log('\nTesting /auth/stats...');
                    return [4 /*yield*/, axios_1.default.get("".concat(BASE_URL, "/auth/stats"))];
                case 7:
                    userStats = _a.sent();
                    console.log('✅ User Stats:', userStats.data);
                    console.log('\n🎉 All dashboard endpoints verified successfully!');
                    return [3 /*break*/, 9];
                case 8:
                    error_1 = _a.sent();
                    console.error('\n❌ Verification Failed:', error_1.message);
                    if (error_1.response) {
                        console.error('Response Data:', error_1.response.data);
                        console.error('Status:', error_1.response.status);
                    }
                    return [3 /*break*/, 9];
                case 9: return [2 /*return*/];
            }
        });
    });
}
verifyEndpoints();
