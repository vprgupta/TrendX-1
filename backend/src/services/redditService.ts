import axios from 'axios';

export const getRedditTrends = async () => {
    try {
        const response = await axios.get('https://www.reddit.com/r/popular.json?limit=10', {
            headers: {
                'User-Agent': 'TrendX-Backend/1.0'
            }
        });

        if (response.status === 200 && response.data.data && response.data.data.children) {
            return response.data.data.children.map((child: any) => {
                const post = child.data;
                return {
                    title: post.title,
                    content: post.selftext || post.url,
                    subreddit: post.subreddit,
                    score: post.score,
                    comments: post.num_comments,
                    author: post.author,
                    url: post.url,
                    thumbnail: post.thumbnail !== 'self' && post.thumbnail !== 'default' ? post.thumbnail : null
                };
            });
        }

        return [];
    } catch (error) {
        console.error('Error fetching Reddit trends:', error instanceof Error ? error.message : String(error));
        return [];
    }
};
