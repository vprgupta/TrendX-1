"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const database_1 = require("../config/database");
const trendScheduler_1 = require("../jobs/trendScheduler");
const Trend_1 = __importDefault(require("../models/Trend"));
const mongoose_1 = __importDefault(require("mongoose"));
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
// Load env from root
dotenv_1.default.config({ path: path_1.default.join(__dirname, '../../.env') });
const verify = async () => {
    try {
        console.log('🧪 Starting Ingestion Verification...');
        // Connect to DB
        await (0, database_1.connectDB)();
        // Count before
        const countBefore = await Trend_1.default.countDocuments();
        console.log(`📊 Trends before: ${countBefore}`);
        // Run Ingestion
        await (0, trendScheduler_1.ingestAllTrends)();
        // Count after
        const countAfter = await Trend_1.default.countDocuments();
        console.log(`📊 Trends after: ${countAfter}`);
        if (countAfter >= countBefore) {
            console.log('✅ Verification Successful: Trends ingested/updated.');
        }
        else {
            console.log('⚠️ Verification Warning: Trend count decreased (unlikely unless DB cleared).');
        }
    }
    catch (error) {
        console.error('❌ Verification Failed:', error);
    }
    finally {
        await mongoose_1.default.disconnect();
        process.exit(0);
    }
};
verify();
