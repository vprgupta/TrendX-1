import axios from 'axios';

const BASE_URL = 'http://localhost:3000/api';

async function verifyEndpoints() {
    console.log('🔍 Verifying Dashboard API Endpoints...');

    try {
        // 1. Verify Analytics Overview
        console.log('\nTesting /analytics/overview...');
        const overview = await axios.get(`${BASE_URL}/analytics/overview`);
        console.log('✅ Overview Data:', JSON.stringify(overview.data, null, 2));

        // 2. Verify Sentiment Analysis
        console.log('\nTesting /analytics/sentiment...');
        const sentiment = await axios.get(`${BASE_URL}/analytics/sentiment`);
        console.log('✅ Sentiment Data:', JSON.stringify(sentiment.data, null, 2));

        // 3. Verify Top Trends
        console.log('\nTesting /analytics/top-trends...');
        const topTrends = await axios.get(`${BASE_URL}/analytics/top-trends`);
        console.log(`✅ Top Trends: Found ${topTrends.data.length} trends`);
        if (topTrends.data.length > 0) {
            console.log('   Sample:', topTrends.data[0].title);
        }

        // 4. Verify Chart Data
        console.log('\nTesting /analytics/chart...');
        const chart = await axios.get(`${BASE_URL}/analytics/chart`);
        console.log(`✅ Chart Data: Found ${chart.data.length} data points`);

        // 5. Verify Integration Status
        console.log('\nTesting /integrations/status...');
        const integrations = await axios.get(`${BASE_URL}/integrations/status`);
        console.log('✅ Integration Status:', JSON.stringify(integrations.data, null, 2));

        // 6. Verify User Stats
        console.log('\nTesting /auth/stats...');
        const userStats = await axios.get(`${BASE_URL}/auth/stats`);
        console.log('✅ User Stats:', JSON.stringify(userStats.data, null, 2));

        console.log('\n🎉 All dashboard endpoints verified successfully!');
    } catch (error: any) {
        console.error('\n❌ Verification Failed:', error.message);
        if (error.response) {
            console.error('Response Data:', error.response.data);
            console.error('Status:', error.response.status);
        }
    }
}

verifyEndpoints();
