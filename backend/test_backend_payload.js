const axios = require('axios');

async function testBackendPayload() {
  const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  const apiKey = 'AIzaSyDCQi_8J6phZsjOPg6K67vwZcaNkX67Giw';

  const title = "SpaceX Starship Launch";
  const content = "SpaceX successfully launched its massive Starship rocket today, reaching orbit for the first time.";
  const platform = "Twitter";
  const language = "English";

  const payload = {
    contents: [{
      parts: [{
        text: `You are an expert news analyst. Use your real-time search capabilities to find the latest context regarding the following ${platform} trend. Then, provide a single, complete explanation in ${language}.\n\nYour entire response must be approximately 50 words long. It should read like a highly optimized, complete news snippet containing the full story: "Who, what, when, where, and why it matters." Do not use any headings or bullet points.\n\nTitle: "${title}"\nContent: "${content}"`
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
      timeout: 30000 
    });
    
    // Check extraction path exactly as it is in the backend:
    if (response.data?.candidates?.[0]?.content?.parts?.[0]?.text) {
      console.log('SUCCESS:', response.data.candidates[0].content.parts[0].text.trim());
    } else {
      console.log('EXTRACTION ERROR! Data shape:', JSON.stringify(response.data, null, 2));
    }
  } catch (error) {
    if (error.response) {
      console.log('API ERROR JSON:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.log('NETWORK ERROR:', error.message);
    }
  }
}

testBackendPayload();
