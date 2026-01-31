const { spawn } = require('child_process');

console.log('🚀 Starting TrendX Backend Server...\n');

const server = spawn('npm', ['run', 'dev'], {
  stdio: 'inherit',
  shell: true
});

server.on('close', (code) => {
  console.log(`\n❌ Server process exited with code ${code}`);
});

server.on('error', (error) => {
  console.error(`❌ Server error: ${error.message}`);
});

process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down server...');
  server.kill('SIGINT');
  process.exit(0);
});