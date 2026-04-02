"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.switchPlatform = exports.syncSession = exports.getActiveSession = exports.endSession = exports.updateSessionActivity = exports.startSession = void 0;
const UserSession_1 = __importDefault(require("../models/UserSession"));
const uuid_1 = require("uuid");
const startSession = async (req, res) => {
    try {
        const { platform = 'web', deviceInfo = {} } = req.body;
        // End any existing active sessions for this user
        await UserSession_1.default.updateMany({ userId: req.user?._id, isActive: true }, {
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
        });
        const sessionId = (0, uuid_1.v4)();
        const session = await UserSession_1.default.create({
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
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to start session' });
    }
};
exports.startSession = startSession;
const updateSessionActivity = async (req, res) => {
    try {
        const { sessionId, activity } = req.body;
        const session = await UserSession_1.default.findOne({
            sessionId,
            userId: req.user?._id,
            isActive: true
        });
        if (!session) {
            return res.status(404).json({ error: 'Active session not found' });
        }
        // Update activity counters
        const updateField = `activities.${activity}`;
        await UserSession_1.default.findByIdAndUpdate(session._id, {
            $inc: { [updateField]: 1 }
        });
        res.json({ message: 'Activity tracked' });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update session activity' });
    }
};
exports.updateSessionActivity = updateSessionActivity;
const endSession = async (req, res) => {
    try {
        const { sessionId } = req.body;
        const session = await UserSession_1.default.findOne({
            sessionId,
            userId: req.user?._id,
            isActive: true
        });
        if (!session) {
            return res.status(404).json({ error: 'Active session not found' });
        }
        const endTime = new Date();
        const duration = Math.floor((endTime.getTime() - session.startTime.getTime()) / 1000);
        await UserSession_1.default.findByIdAndUpdate(session._id, {
            endTime,
            duration,
            isActive: false
        });
        res.json({
            message: 'Session ended',
            duration
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to end session' });
    }
};
exports.endSession = endSession;
const getActiveSession = async (req, res) => {
    try {
        const session = await UserSession_1.default.findOne({
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
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to get active session' });
    }
};
exports.getActiveSession = getActiveSession;
const syncSession = async (req, res) => {
    try {
        const { platform } = req.body;
        let session = await UserSession_1.default.findOne({
            userId: req.user?._id,
            isActive: true
        });
        if (!session) {
            const sessionId = (0, uuid_1.v4)();
            session = await UserSession_1.default.create({
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
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to sync session' });
    }
};
exports.syncSession = syncSession;
const switchPlatform = async (req, res) => {
    try {
        const { sessionId, newPlatform } = req.body;
        await UserSession_1.default.findOneAndUpdate({ sessionId, userId: req.user?._id, isActive: true }, { platform: newPlatform });
        res.json({ message: 'Platform switched' });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to switch platform' });
    }
};
exports.switchPlatform = switchPlatform;
