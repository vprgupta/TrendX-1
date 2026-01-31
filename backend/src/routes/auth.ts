import express from 'express';
import * as authController from '../controllers/authController';
import { validateRegister, validateLogin } from '../middleware/validation';
import { authenticate } from '../middleware/auth';

const router = express.Router();

// Authentication routes
router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/logout', authenticate, authController.logout);
router.post('/refresh', authController.refreshAccessToken);

// Email verification
router.get('/verify-email/:token', authController.verifyEmail);

// Password reset
router.post('/request-password-reset', authController.requestPasswordReset);
router.post('/reset-password/:token', authController.resetPassword);

// Admin user management
router.get('/users', authController.getAllUsers);
router.get('/stats', authController.getUserStats);
router.post('/users', authenticate, authController.createUser);
router.put('/users/:id', authenticate, authController.updateUser);
router.delete('/users/:id', authenticate, authController.deleteUser);
router.patch('/users/:id/status', authenticate, authController.updateUserStatus);

export default router;