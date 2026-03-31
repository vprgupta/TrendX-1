const axios = require('axios');

async function testGemini() {
  const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  const apiKey = 'AIzaSyDCQi_8J6phZsjOPg6K67vwZcaNkX67Giw';

  const payload = {
    contents: [{
      parts: [{
        text: 'hello'
      }]
    }],
    tools: [{
        googleSearch: {}
    }],
    generationConfig: {
      maxOutputTokens: 150,
      temperature: 0.5
    }
  };

  try {
    const response = await axios.post(`${GEMINI_API_URL}?key=${apiKey}`, payload, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000 // 10 seconds
    });
    console.log('SUCCESS:', response.data.candidates[0].content.parts[0].text);
  } catch (error) {
    if (error.response) {
      console.log('ERROR JSON:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.log('ERROR:', error.message);
    }
  }
}

testGemini();
