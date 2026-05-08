const io = require('socket.io-client');

const serverUrl = 'https://heartsync-server-oe8w.onrender.com';
const roomCode = 'TEST1234';

console.log('Connecting Client A...');
const clientA = io(serverUrl, { transports: ['websocket'] });

console.log('Connecting Client B...');
const clientB = io(serverUrl, { transports: ['websocket'] });

let aConnected = false;
let bConnected = false;

clientA.on('connect', () => {
  console.log('Client A connected!');
  aConnected = true;
  clientA.emit('join_room', roomCode);
});

clientB.on('connect', () => {
  console.log('Client B connected!');
  bConnected = true;
  clientB.emit('join_room', roomCode);
});

clientA.on('sync_event', (data) => {
  console.log('[Client A received sync_event]:', data);
});

clientB.on('sync_event', (data) => {
  console.log('[Client B received sync_event]:', data);
});

clientA.on('partner_online', (data) => {
    console.log('[Client A] Partner Online:', data);
});

clientB.on('partner_online', (data) => {
    console.log('[Client B] Partner Online:', data);
    
    // Once both are in, Client A sends a watch command
    setTimeout(() => {
        console.log('\n--- Client A sends Play command ---');
        clientA.emit('sync_event', {
            roomId: roomCode,
            type: 'watch_command',
            data: {
                action: 'play',
                timestamp: 123456,
                videoUrl: 'https://youtube.com/test'
            }
        });
    }, 2000);
});

// Wait 10 seconds then disconnect
setTimeout(() => {
  console.log('\nTest completed. Disconnecting...');
  clientA.disconnect();
  clientB.disconnect();
  process.exit(0);
}, 15000);
