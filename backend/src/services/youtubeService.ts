import axios from 'axios';

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;

export const getYouTubeTrends = async (country: string = 'US', category: string = '28') => {
  // If API key is available, use YouTube Data API v3
  if (YOUTUBE_API_KEY) {
    try {
      const response = await axios.get(
        'https://www.googleapis.com/youtube/v3/videos',
        {
          params: {
            part: 'snippet,statistics',
            chart: 'mostPopular',
            regionCode: country,
            maxResults: 20,
            videoCategoryId: category, // 28 = Science & Technology
            key: YOUTUBE_API_KEY
          }
        }
      );

      return response.data.items.map((item: any) => ({
        id: item.id,
        title: item.snippet.title,
        description: item.snippet.description,
        thumbnail: item.snippet.thumbnails.high?.url || item.snippet.thumbnails.medium?.url,
        channelTitle: item.snippet.channelTitle,
        views: parseInt(item.statistics.viewCount || '0'),
        likes: parseInt(item.statistics.likeCount || '0'),
        comments: parseInt(item.statistics.commentCount || '0'),
        publishedAt: item.snippet.publishedAt,
        url: `https://www.youtube.com/watch?v=${item.id}`
      }));
    } catch (error) {
      console.error('YouTube API error, using mock data:', error);
    }
  }

  // Fallback to mock data
  return getMockYouTubeTrends();
};

export const getYouTubeVideos = async (query: string) => {
  if (YOUTUBE_API_KEY) {
    try {
      const response = await axios.get(
        'https://www.googleapis.com/youtube/v3/search',
        {
          params: {
            part: 'snippet',
            q: query,
            type: 'video',
            maxResults: 10,
            order: 'viewCount',
            key: YOUTUBE_API_KEY
          }
        }
      );

      return response.data.items.map((item: any) => ({
        id: item.id.videoId,
        title: item.snippet.title,
        description: item.snippet.description,
        thumbnail: item.snippet.thumbnails.medium.url,
        channelTitle: item.snippet.channelTitle,
        publishedAt: item.snippet.publishedAt,
        url: `https://www.youtube.com/watch?v=${item.id.videoId}`
      }));
    } catch (error) {
      console.error('YouTube search error:', error);
    }
  }

  return [];
};

// Mock data fallback
const getMockYouTubeTrends = () => {
  return [
    {
      title: "Top 10 Tech Trends 2026",
      channelTitle: "Tech Daily",
      thumbnail: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
      id: "mock1",
      views: 1500000,
      likes: 45000,
      comments: 3200,
      description: "Exploring the latest technology trends",
      publishedAt: new Date().toISOString(),
      url: "https://www.youtube.com/watch?v=mock1"
    },
    {
      title: "SpaceX Launch Highlights",
      channelTitle: "Space News",
      thumbnail: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
      id: "mock2",
      views: 2300000,
      likes: 78000,
      comments: 5400,
      description: "Latest SpaceX mission highlights",
      publishedAt: new Date().toISOString(),
      url: "https://www.youtube.com/watch?v=mock2"
    },
    {
      title: "New AI Model Released",
      channelTitle: "AI Insider",
      thumbnail: "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
      id: "mock3",
      views: 980000,
      likes: 32000,
      comments: 2100,
      description: "Revolutionary AI model announcement",
      publishedAt: new Date().toISOString(),
      url: "https://www.youtube.com/watch?v=mock3"
    }
  ];
};