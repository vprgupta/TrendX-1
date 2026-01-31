const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/trendx')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// User schema (simplified)
const userSchema = new mongoose.Schema({
  email: String,
  password: String,
  name: String
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

async function debugAuth() {
  try {
    // Check all users
    const users = await User.find({});
    console.log('\n📊 All users in database:');
    users.forEach(user => {
      console.log(`- Email: ${user.email}, Name: ${user.name}, ID: ${user._id}`);
    });

    if (users.length === 0) {
      console.log('\n⚠️  No users found in database!');
      console.log('Try registering a user first.');
      return;
    }

    // Test password comparison for first user
    const testUser = users[0];
    console.log(`\n🔍 Testing password for: ${testUser.email}`);
    
    // Try common passwords
    const testPasswords = ['123456', 'password', 'test123', 'admin123'];
    
    for (const pwd of testPasswords) {
      const isMatch = await bcrypt.compare(pwd, testUser.password);
      console.log(`Password "${pwd}": ${isMatch ? '✅ MATCH' : '❌ No match'}`);
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    mongoose.connection.close();
  }
}

debugAuth();