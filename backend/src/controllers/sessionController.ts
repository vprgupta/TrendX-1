import { Response } from 'express';
import UserSession from '../models/UserSession';
import { AuthRequest } from '../types';
import { v4 as uuidv4 } from 'uuid';

export const startSession = async (req: AuthRequest, res: Response) => {
  try {
    const { platform = 'web', deviceInfo = {} } = req.body;
    
    // End any existing active sessions for this user
    await UserSession.updateMany(
      { userId: req.user?._id, isActive: true },
      { 
        isActive: false, 
        endTime: new Date(),
        $set: {
          duration: {
            $divide: [
              { $subtract: ['$endTime', '$startTime'] },
              1000
            ]
          }
        }
      }
    );

    const sessionId = uuidv4();
    const session = await UserSession.create({
      userId: req.user?._id,
      sessionId,
      platform,
      deviceInfo: {
        ...deviceInfo,
        ip: req.ip,
        userAgent: req.get('User-Agent')
      }
    });

    res.json({ 
      message: 'Session started',
      sessionId: session.sessionId
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to start session' });
  }
};

export const updateSessionActivity = async (req: AuthRequest, res: Response) => {
  try {
    const { sessionId, activity } = req.body;
    
    const session = await UserSession.findOne({ 
      sessionId, 
      userId: req.user?._id,
      isActive: true 
    });

    if (!session) {
      return res.status(404).json({ error: 'Active session not found' });
    }

    // Update activity counters
    const updateField = `activities.${activity}`;
    await UserSession.findByIdAndUpdate(session._id, {
      $inc: { [updateField]: 1 }
    });

    res.json({ message: 'Activity tracked' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update session activity' });
  }
};

export const endSession = async (req: AuthRequest, res: Response) => {
  try {
    const { sessionId } = req.body;
    
    const session = await UserSession.findOne({ 
      sessionId, 
      userId: req.user?._id,
      isActive: true 
    });

    if (!session) {
      return res.status(404).json({ error: 'Active session not found' });
    }

    const endTime = new Date();
    const duration = Math.floor((endTime.getTime() - session.startTime.getTime()) / 1000);

    await UserSession.findByIdAndUpdate(session._id, {
      endTime,
      duration,
      isActive: false
    });

    res.json({ 
      message: 'Session ended',
      duration
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to end session' });
  }
};

export const getActiveSession = async (req: AuthRequest, res: Response) => {
  try {
    const session = await UserSession.findOne({ 
      userId: req.user?._id,
      isActive: true 
    });

    if (!session) {
      return res.status(404).json({ error: 'No active session found' });
    }

    const currentDuration = Math.floor((new Date().getTime() - session.startTime.getTime()) / 1000);

    res.json({
      session: {
        ...session.toObject(),
        currentDuration
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get active session' });
  }
};

export const syncSession = async (req: AuthRequest, res: Response) => {
  try {
    const { platform } = req.body;
    
    let session = await UserSession.findOne({ 
      userId: req.user?._id,
      isActive: true 
    });

    if (!session) {
      const sessionId = uuidv4();
      session = await UserSession.create({
        userId: req.user?._id,
        sessionId,
        platform,
        deviceInfo: {
          ip: req.ip,
          userAgent: req.get('User-Agent')
        }
      });
    }

    res.json({ 
      sessionId: session.sessionId,
      platform: session.platform,
      startTime: session.startTime
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to sync session' });
  }
};

export const switchPlatform = async (req: AuthRequest, res: Response) => {
  try {
    const { sessionId, newPlatform } = req.body;
    
    await UserSession.findOneAndUpdate(
      { sessionId, userId: req.user?._id, isActive: true },
      { platform: newPlatform }
    );

    res.json({ message: 'Platform switched' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to switch platform' });
  }
};