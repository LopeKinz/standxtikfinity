# Stand x Tikfinity Connector

**Stand x Tikfinity Connector** is a powerful and easy-to-use tool designed to boost TikTok engagement by connecting **Tikfinity** with **Stand** in GTA 5. The tool triggers in-game actions based on TikTok events such as joins, likes, shares, follows, subscriptions, and gifts. Customize everything via the intuitive GUI in Stand for a seamless and engaging experience.

---

## Features
- **TikTok Event Integration**: Automate responses to TikTok events like follows, likes, shares, and more.
- **Customizable Commands**: Use the Stand GUI to set up unique in-game actions for each TikTok event.
- **Streamlined Setup**: Easily bridge Tikfinity and Stand using this tool with minimal configuration.
- **Event Support**: Includes all major TikTok events: Join, Like, Share, Follow, Subscribe, and Gift.

---

## Setup Guide

### Prerequisites
1. **Tikfinity**: Download the app from [here](https://tikfinity.zerody.one/app/).  
2. **Stand Mod**: Ensure you have the Stand mod installed and running in GTA 5 (Singleplayer or Multiplayer).  
3. **Node.js**: Download and install [Node.js](https://nodejs.org) (required to run `Fix.js`).  
4. **Visual Studio Code (VS Code)**: Download and install [VS Code](https://code.visualstudio.com).  

---

### Installation Steps

#### 1. Download and Set Up Tikfinity
- Go to [Tikfinity](https://tikfinity.zerody.one/app/) and download the app.  
- Connect Tikfinity to your TikTok account.

#### 2. Clone This Repository
- Clone the repository and navigate to the project folder:  
  ```bash
  git clone https://github.com/LopeKinz/standxtikfinity.git
  cd standxtikfinity
  ```

#### 3. Install Dependencies
- Use Node.js to install the required dependencies for `Fix.js`:  
  ```bash
  npm install
  ```

#### 4. Run `Fix.js`
- Start the `Fix.js` script in VS Code or your terminal:  
  ```bash
  node Fix.js
  ```
- This script translates WebSocket events from Tikfinity into JSON files that Stand can read.

#### 5. Configure Stand
- Launch GTA 5 in **Singleplayer** (or Multiplayer) and open Stand.  
- Load the Lua script included in this repository.  
- Ensure internet access is enabled for Stand.  
- Set the URL in the script to one of the following:
  - `http://localhost:3000`
  - `http://127.0.0.1:3000`

#### 6. Start Streaming
- Go live on TikTok using Tikfinity.
- Sit back and watch your TikTok events trigger in-game commands in GTA 5.

---

## Troubleshooting
- **`Fix.js` Errors**: Make sure Node.js is installed, and dependencies are properly installed with `npm install`.  
- **Connection Issues**: Ensure the URLs match in both Stand and Tikfinity.  
- **Event Trigger Problems**: Verify that the Lua script is running and correctly configured in Stand.  
- For more help, check the repository's [Issues](https://github.com/LopeKinz/standxtikfinity/issues) section.

---

### Note for Stand Staff  
The `Fix.js` file is required because Stand does not natively support WebSocket connections. This script converts WebSocket events into JSON files that Stand can process through its browser functionality. This approach ensures smooth integration without requiring native WebSocket support.

**Please don't ban me again!**

---

GitHub: [Stand x Tikfinity Connector](https://github.com/LopeKinz/standxtikfinity)
