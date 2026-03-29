import { Request, Response } from 'express';
import { explainTrendWithGemini } from '../services/aiExplainerService';
import logger from '../utils/logger';

export const explainContent = async (req: Request, res: Response) => {
  try {
    const { title, content, platform, language } = req.body;

    if (!title || !content || !platform) {
      return res.status(400).json({
        success: false,
        error: 'title, content, and platform are required fields'
      });
    }

    const explanation = await explainTrendWithGemini(
       title,
       content,
       platform,
       language || 'English'
    );

    res.json({
      success: true,
      explanation
    });

  } catch (error: any) {
    logger.error('Error generating AI explanation', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to generate explanation. Check backend logs'
    });
  }
};
