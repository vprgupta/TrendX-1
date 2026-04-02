"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateUserStatus = exports.deleteUser = exports.updateUser = exports.createUser = exports.getUserStats = exports.getAllUsers = exports.resetPassword = exports.requestPasswordReset = exports.verifyEmail = exports.logout = exports.refreshAccessToken = exports.login = exports.register = void 0;
const crypto_1 = __importDefault(require("crypto"));
const User_1 = __importDefault(require("../models/User"));
const jwt_1 = require("../utils/jwt");
/**
 * Generate verification token
 */
const generateVerificationToken = () => {
    return crypto_1.default.randomBytes(32).toString('hex');
};
/**
 * Register with email verification
 */
const register = async (req, res) => {
    console.log('👉 Register endpoint hit. Body:', JSON.stringify(req.body, null, 2));
    const { email, password, name } = req.body;
    const existingUser = await User_1.default.findOne({ email });
    if (existingUser) {
        return res.status(400).json({ error: 'Email already registered' });
    }
    // Generate email verification token
    const emailVerificationToken = generateVerificationToken();
    const emailVerificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours
    const user = await User_1.default.create({
        email,
        password,
        name,
        emailVerificationToken,
        emailVerificationExpires,
        emailVerified: false
    });
    console.log('🎉 New user registered:', { email, name, id: user._id });
    const accessToken = (0, jwt_1.generateAccessToken)(user._id.toString());
    const refreshToken = (0, jwt_1.generateRefreshToken)(user._id.toString());
    // Save refresh token to user
    user.refreshToken = refreshToken;
    await user.save();
    // TODO: Send verification email (implement emailService)
    console.log('📧 Verification token:', emailVerificationToken);
    res.status(201).json({
        message: 'User registered successfully. Please verify your email.',
        accessToken,
        refreshToken,
        user: {
            id: user._id,
            email: user.email,
            name: user.name,
            emailVerified: user.emailVerified
        }
    });
};
exports.register = register;
/**
 * Login with refresh token
 */
const login = async (req, res) => {
    const { email, password } = req.body;
    console.log('🔐 Login attempt:', email);
    const user = await User_1.default.findOne({ email });
    if (!user) {
        console.log('❌ User not found:', email);
        return res.status(401).json({ error: 'Invalid credentials' });
    }
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
    }
    const accessToken = (0, jwt_1.generateAccessToken)(user._id.toString());
    const refreshToken = (0, jwt_1.generateRefreshToken)(user._id.toString());
    // Save refresh token
    user.refreshToken = refreshToken;
    user.lastActive = new Date();
    await user.save();
    console.log('✅ Login successful:', email);
    res.json({
        message: 'Login successful',
        accessToken,
        refreshToken,
        user: {
            id: user._id,
            email: user.email,
            name: user.name,
            emailVerified: user.emailVerified,
            preferences: user.preferences
        }
    });
};
exports.login = login;
/**
 * Refresh access token using refresh token
 */
const refreshAccessToken = async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) {
        return res.status(400).json({ error: 'Refresh token required' });
    }
    try {
        const decoded = (0, jwt_1.verifyRefreshToken)(refreshToken);
        const user = await User_1.default.findById(decoded.userId);
        if (!user || user.refreshToken !== refreshToken) {
            return res.status(401).json({ error: 'Invalid refresh token' });
        }
        const newAccessToken = (0, jwt_1.generateAccessToken)(user._id.toString());
        res.json({
            message: 'Token refreshed successfully',
            accessToken: newAccessToken
        });
    }
    catch (error) {
        res.status(401).json({ error: 'Invalid or expired refresh token' });
    }
};
exports.refreshAccessToken = refreshAccessToken;
/**
 * Logout - invalidate refresh token
 */
const logout = async (req, res) => {
    try {
        if (req.user?._id) {
            await User_1.default.findByIdAndUpdate(req.user._id, { refreshToken: null });
        }
        console.log('🚪 User logged out');
        res.json({
            message: 'Logout successful'
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Logout failed' });
    }
};
exports.logout = logout;
/**
 * Verify email address
 */
const verifyEmail = async (req, res) => {
    const { token } = req.params;
    const user = await User_1.default.findOne({
        emailVerificationToken: token,
        emailVerificationExpires: { $gt: new Date() }
    });
    if (!user) {
        return res.status(400).json({ error: 'Invalid or expired verification token' });
    }
    user.emailVerified = true;
    user.emailVerificationToken = undefined;
    user.emailVerificationExpires = undefined;
    await user.save();
    console.log('✅ Email verified for:', user.email);
    res.json({
        message: 'Email verified successfully',
        user: {
            id: user._id,
            email: user.email,
            emailVerified: user.emailVerified
        }
    });
};
exports.verifyEmail = verifyEmail;
/**
 * Request password reset
 */
const requestPasswordReset = async (req, res) => {
    const { email } = req.body;
    const user = await User_1.default.findOne({ email });
    if (!user) {
        // Don't reveal if email exists for security
        return res.json({ message: 'If email exists, reset link has been sent' });
    }
    const resetToken = generateVerificationToken();
    const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = resetExpires;
    await user.save();
    // TODO: Send password reset email (implement emailService)
    console.log('🔑 Password reset token for', email, ':', resetToken);
    res.json({
        message: 'If email exists, reset link has been sent'
    });
};
exports.requestPasswordReset = requestPasswordReset;
/**
 * Reset password using token
 */
const resetPassword = async (req, res) => {
    const { token } = req.params;
    const { newPassword } = req.body;
    if (!newPassword || newPassword.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }
    const user = await User_1.default.findOne({
        resetPasswordToken: token,
        resetPasswordExpires: { $gt: new Date() }
    });
    if (!user) {
        return res.status(400).json({ error: 'Invalid or expired reset token' });
    }
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    user.refreshToken = undefined; // Invalidate all sessions
    await user.save();
    console.log('🔐 Password reset successful for:', user.email);
    res.json({
        message: 'Password reset successful. Please login with your new password.'
    });
};
exports.resetPassword = resetPassword;
// ===== ADMIN FUNCTIONS (keep existing) =====
const getAllUsers = async (req, res) => {
    const users = await User_1.default.find({}).select('-password').sort({ createdAt: -1 });
    console.log(`📊 Users requested - Total: ${users.length}`);
    res.json({
        users,
        count: users.length,
        message: `Found ${users.length} registered users`
    });
};
exports.getAllUsers = getAllUsers;
const getUserStats = async (req, res) => {
    try {
        const totalUsers = await User_1.default.countDocuments();
        const activeUsers = await User_1.default.countDocuments({ emailVerified: true });
        const newUsers = await User_1.default.countDocuments({
            createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
        });
        res.json({
            total: totalUsers,
            active: activeUsers,
            new: newUsers,
            admin: 1,
            blocked: 0
        });
    }
    catch (error) {
        console.error('Error fetching user stats:', error);
        res.status(500).json({ error: 'Failed to fetch user stats' });
    }
};
exports.getUserStats = getUserStats;
const createUser = async (req, res) => {
    try {
        const { email, password, name, role } = req.body;
        const existingUser = await User_1.default.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'Email already registered' });
        }
        const user = await User_1.default.create({ email, password, name, role });
        res.status(201).json({
            message: 'User created successfully',
            user: {
                id: user._id,
                email: user.email,
                name: user.name,
                role: user.role
            }
        });
    }
    catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Failed to create user' });
    }
};
exports.createUser = createUser;
const updateUser = async (req, res) => {
    try {
        const { name, email, role } = req.body;
        const user = await User_1.default.findByIdAndUpdate(req.params.id, { name, email, role }, { new: true, runValidators: true }).select('-password');
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ message: 'User updated successfully', user });
    }
    catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ error: 'Failed to update user' });
    }
};
exports.updateUser = updateUser;
const deleteUser = async (req, res) => {
    try {
        const user = await User_1.default.findByIdAndDelete(req.params.id);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ message: 'User deleted successfully' });
    }
    catch (error) {
        console.error('Error deleting user:', error);
        res.status(500).json({ error: 'Failed to delete user' });
    }
};
exports.deleteUser = deleteUser;
const updateUserStatus = async (req, res) => {
    try {
        const { status } = req.body;
        const user = await User_1.default.findByIdAndUpdate(req.params.id, { status }, { new: true }).select('-password');
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ message: 'User status updated successfully', user });
    }
    catch (error) {
        console.error('Error updating user status:', error);
        res.status(500).json({ error: 'Failed to update user status' });
    }
};
exports.updateUserStatus = updateUserStatus;
