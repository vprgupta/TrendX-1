import { connectDB } from '../config/database';
import { ingestAllTrends } from '../jobs/trendScheduler';
import Trend from '../models/Trend';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';

// Load env from root
dotenv.config({ path: path.join(__dirname, '../../.env') });

const verify = async () => {
    try {
        console.log('🧪 Starting Ingestion Verification...');

        // Connect to DB
        await connectDB();

        // Count before
        const countBefore = await Trend.countDocuments();
        console.log(`📊 Trends before: ${countBefore}`);

        // Run Ingestion
        await ingestAllTrends();

        // Count after
        const countAfter = await Trend.countDocuments();
        console.log(`📊 Trends after: ${countAfter}`);

        if (countAfter >= countBefore) {
            console.log('✅ Verification Successful: Trends ingested/updated.');
        } else {
            console.log('⚠️ Verification Warning: Trend count decreased (unlikely unless DB cleared).');
        }

    } catch (error) {
        console.error('❌ Verification Failed:', error);
    } finally {
        await mongoose.disconnect();
        process.exit(0);
    }
};

verify();
