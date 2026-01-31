import { Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { AuthRequest } from '../types';
import User from '../models/User';

// Configure multer for avatar uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, '../../public/uploads/avatars');
        // Create directory if it doesn't exist
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const userId = (req as AuthRequest).user?._id;
        const ext = path.extname(file.originalname);
        cb(null, `avatar-${userId}-${Date.now()}${ext}`);
    }
});

const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
    // Accept images only
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed!'));
    }
};

export const upload = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB limit
    }
});

/**
 * Upload user avatar
 * POST /api/users/me/avatar
 */
export const uploadAvatar = async (req: AuthRequest, res: Response) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        // Generate public URL for the avatar
        const avatarUrl = `/uploads/avatars/${req.file.filename}`;

        // Update user's avatar in database
        const user = await User.findByIdAndUpdate(
            req.user?._id,
            { avatar: avatarUrl },
            { new: true }
        ).select('-password');

        res.json({
            message: 'Avatar uploaded successfully',
            avatar: avatarUrl,
            user
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to upload avatar' });
    }
};
