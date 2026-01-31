import crypto from 'crypto';
import { Request, Response } from 'express';
import User from '../models/User';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from '../utils/jwt';
import { AuthRequest } from '../types';

/**
 * Generate verification token
 */
const generateVerificationToken = (): string => {
  return crypto.randomBytes(32).toString('hex');
};

/**
 * Register with email verification
 */
export const register = async (req: Request, res: Response) => {
  console.log('👉 Register endpoint hit. Body:', JSON.stringify(req.body, null, 2));
  const { email, password, name } = req.body;

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return res.status(400).json({ error: 'Email already registered' });
  }

  // Generate email verification token
  const emailVerificationToken = generateVerificationToken();
  const emailVerificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

  const user = await User.create({
    email,
    password,
    name,
    emailVerificationToken,
    emailVerificationExpires,
    emailVerified: false
  });

  console.log('🎉 New user registered:', { email, name, id: user._id });

  const accessToken = generateAccessToken(user._id.toString());
  const refreshToken = generateRefreshToken(user._id.toString());

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

/**
 * Login with refresh token
 */
export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;
  console.log('🔐 Login attempt:', email);

  const user = await User.findOne({ email });
  if (!user) {
    console.log('❌ User not found:', email);
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const accessToken = generateAccessToken(user._id.toString());
  const refreshToken = generateRefreshToken(user._id.toString());

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

/**
 * Refresh access token using refresh token
 */
export const refreshAccessToken = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(400).json({ error: 'Refresh token required' });
  }

  try {
    const decoded = verifyRefreshToken(refreshToken);
    const user = await User.findById(decoded.userId);

    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const newAccessToken = generateAccessToken(user._id.toString());

    res.json({
      message: 'Token refreshed successfully',
      accessToken: newAccessToken
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid or expired refresh token' });
  }
};

/**
 * Logout - invalidate refresh token
 */
export const logout = async (req: AuthRequest, res: Response) => {
  try {
    if (req.user?._id) {
      await User.findByIdAndUpdate(req.user._id, { refreshToken: null });
    }

    console.log('🚪 User logged out');
    res.json({
      message: 'Logout successful'
    });
  } catch (error) {
    res.status(500).json({ error: 'Logout failed' });
  }
};

/**
 * Verify email address
 */
export const verifyEmail = async (req: Request, res: Response) => {
  const { token } = req.params;

  const user = await User.findOne({
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

/**
 * Request password reset
 */
export const requestPasswordReset = async (req: Request, res: Response) => {
  const { email } = req.body;

  const user = await User.findOne({ email });
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

/**
 * Reset password using token
 */
export const resetPassword = async (req: Request, res: Response) => {
  const { token } = req.params;
  const { newPassword } = req.body;

  if (!newPassword || newPassword.length < 6) {
    return res.status(400).json({ error: 'Password must be at least 6 characters' });
  }

  const user = await User.findOne({
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

// ===== ADMIN FUNCTIONS (keep existing) =====

export const getAllUsers = async (req: Request, res: Response) => {
  const users = await User.find({}).select('-password').sort({ createdAt: -1 });
  console.log(`📊 Users requested - Total: ${users.length}`);
  res.json({
    users,
    count: users.length,
    message: `Found ${users.length} registered users`
  });
};

export const getUserStats = async (req: Request, res: Response) => {
  try {
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ emailVerified: true });
    const newUsers = await User.countDocuments({
      createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
    });

    res.json({
      total: totalUsers,
      active: activeUsers,
      new: newUsers,
      admin: 1,
      blocked: 0
    });
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({ error: 'Failed to fetch user stats' });
  }
};

export const createUser = async (req: Request, res: Response) => {
  try {
    const { email, password, name, role } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const user = await User.create({ email, password, name, role });

    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Failed to create user' });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    const { name, email, role } = req.body;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { name, email, role },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: 'User updated successfully', user });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: 'Failed to delete user' });
  }
};

export const updateUserStatus = async (req: Request, res: Response) => {
  try {
    const { status } = req.body;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: 'User status updated successfully', user });
  } catch (error) {
    console.error('Error updating user status:', error);
    res.status(500).json({ error: 'Failed to update user status' });
  }
};
