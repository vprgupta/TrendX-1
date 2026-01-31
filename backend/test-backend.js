const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testBackend() {
  console.log('🧪 Testing TrendX Backend API...\n');

  try {
    // Test 1: Health Check
    console.log('1. Testing Health Check...');
    const healthResponse = await axios.get(`${BASE_URL}/api/health`);
    console.log('✅ Health Check:', healthResponse.data);
    console.log('');

    // Test 2: Get Trends (should work without auth)
    console.log('2. Testing Get Trends...');
    const trendsResponse = await axios.get(`${BASE_URL}/api/trends`);
    console.log('✅ Trends Response:', {
      status: trendsResponse.status,
      trendsCount: trendsResponse.data.trends?.length || 0,
      pagination: trendsResponse.data.pagination
    });
    console.log('');

    // Test 3: User Registration
    console.log('3. Testing User Registration...');
    const testUser = {
      name: 'Test User',
      email: `test${Date.now()}@example.com`,
      password: 'password123'
    };
    
    try {
      const registerResponse = await axios.post(`${BASE_URL}/api/auth/register`, testUser);
      console.log('✅ Registration Success:', {
        status: registerResponse.status,
        message: registerResponse.data.message,
        hasToken: !!registerResponse.data.token
      });
      
      // Test 4: User Login
      console.log('4. Testing User Login...');
      const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
        email: testUser.email,
        password: testUser.password
      });
      console.log('✅ Login Success:', {
        status: loginResponse.status,
        message: loginResponse.data.message,
        hasToken: !!loginResponse.data.token
      });
      
      const token = loginResponse.data.token;
      
      // Test 5: Protected Route (Create Trend)
      console.log('5. Testing Protected Route (Create Trend)...');
      const newTrend = {
        title: 'Test Trend',
        content: 'This is a test trend for API validation',
        platform: 'youtube',
        category: 'technology',
        country: 'global'
      };
      
      const createTrendResponse = await axios.post(`${BASE_URL}/api/trends`, newTrend, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Create Trend Success:', {
        status: createTrendResponse.status,
        message: createTrendResponse.data.message,
        trendId: createTrendResponse.data.trend._id
      });
      
    } catch (authError) {
      console.log('❌ Auth Error:', authError.response?.data || authError.message);
    }

    // Test 6: Search Trends
    console.log('6. Testing Search Trends...');
    try {
      const searchResponse = await axios.get(`${BASE_URL}/api/trends/search?q=test`);
      console.log('✅ Search Success:', {
        status: searchResponse.status,
        resultsCount: searchResponse.data.count
      });
    } catch (searchError) {
      console.log('✅ Search (no results):', searchError.response?.status || 'No error');
    }

    // Test 7: Platform-specific Trends
    console.log('7. Testing Platform-specific Trends...');
    try {
      const platformResponse = await axios.get(`${BASE_URL}/api/trends/platform/youtube`);
      console.log('✅ Platform Trends:', {
        status: platformResponse.status,
        platform: platformResponse.data.platform,
        trendsCount: platformResponse.data.count
      });
    } catch (platformError) {
      console.log('✅ Platform Trends (no results):', platformError.response?.status || 'No error');
    }

    console.log('\n🎉 Backend API Test Complete!');
    
  } catch (error) {
    console.error('❌ Backend Test Failed:', error.message);
    if (error.code === 'ECONNREFUSED') {
      console.log('💡 Make sure the backend server is running on port 5000');
      console.log('   Run: cd backend && npm run dev');
    }
  }
}

testBackend();