// 1) Install needed packages first:
//    npm install ws express cors
//
// 2) Run this script via:
//    node bridge.js

const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');

///////////////////////////////////////////////////////////////////////////////
// CONFIG
///////////////////////////////////////////////////////////////////////////////
const WS_URL = 'ws://localhost:21213';  // Tikfinity WS endpoint
const HTTP_PORT = 3000;                 // Port for our local HTTP server

///////////////////////////////////////////////////////////////////////////////
// IN-MEMORY EVENT STORE
///////////////////////////////////////////////////////////////////////////////
// We'll store events in an array. When Stand requests them, we return & clear.
let eventsQueue = [];

// This function adds a raw JSON event to the queue.
function storeEvent(rawJson) {
  eventsQueue.push(rawJson);
}

///////////////////////////////////////////////////////////////////////////////
// WEBSOCKET CLIENT
///////////////////////////////////////////////////////////////////////////////
function connectWebSocket() {
  console.log(`Connecting to WebSocket: ${WS_URL}`);
  const ws = new WebSocket(WS_URL);

  ws.on('open', () => {
    console.log('WS connected:', WS_URL);
  });

  ws.on('message', (data) => {
    console.log('WS message received:', data);

    // We expect data to be JSON from Tikfinity, e.g. { "event": "chat", ... }
    // Just store it as a string in our eventsQueue:
    storeEvent(data.toString());
  });

  ws.on('error', (err) => {
    console.error('WS error:', err.message);
  });

  ws.on('close', () => {
    console.log('WS closed. Reconnecting in 3 seconds...');
    setTimeout(connectWebSocket, 3000);
  });
}

// Start the WebSocket connection
connectWebSocket();

///////////////////////////////////////////////////////////////////////////////
// EXPRESS HTTP SERVER
///////////////////////////////////////////////////////////////////////////////
const app = express();
app.use(cors()); // allow cross-origin requests, if needed

// GET /events returns all queued events (and clears them)
app.get('/events', (req, res) => {
  // We'll return the entire array as JSON
  const toSend = eventsQueue;
  eventsQueue = []; // clear them after sending

  res.json({ events: toSend });
});

// Start listening
app.listen(HTTP_PORT, () => {
  console.log(`HTTP server running on http://localhost:${HTTP_PORT}/`);
  console.log(`Use GET /events to retrieve queued events.`);
});
