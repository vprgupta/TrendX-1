"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadAvatar = exports.upload = void 0;
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const User_1 = __importDefault(require("../models/User"));
// Configure multer for avatar uploads
const storage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path_1.default.join(__dirname, '../../public/uploads/avatars');
        // Create directory if it doesn't exist
        if (!fs_1.default.existsSync(uploadDir)) {
            fs_1.default.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const userId = req.user?._id;
        const ext = path_1.default.extname(file.originalname);
        cb(null, `avatar-${userId}-${Date.now()}${ext}`);
    }
});
const fileFilter = (req, file, cb) => {
    // Accept images only
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    }
    else {
        cb(new Error('Only image files are allowed!'));
    }
};
exports.upload = (0, multer_1.default)({
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
const uploadAvatar = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }
        // Generate public URL for the avatar
        const avatarUrl = `/uploads/avatars/${req.file.filename}`;
        // Update user's avatar in database
        const user = await User_1.default.findByIdAndUpdate(req.user?._id, { avatar: avatarUrl }, { new: true }).select('-password');
        res.json({
            message: 'Avatar uploaded successfully',
            avatar: avatarUrl,
            user
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to upload avatar' });
    }
};
exports.uploadAvatar = uploadAvatar;
