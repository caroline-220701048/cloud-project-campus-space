import dotenv from "dotenv";
dotenv.config();
import express from "express";
import cors from "cors";

import roomRoutes from "./routes/rooms.js";
import bookingRoutes from "./routes/bookings.js";
import userRoutes from "./routes/users.js";

const app = express();
app.use(cors());
app.use(express.json());
const rawPort = process.env.PORT ?? process.env.WEBSITE_PORT ?? "5000";
const isPipe = (p) => typeof p === 'string' && (p.startsWith('\\\\.\\pipe\\') || p.startsWith('/'));

let port;
if (isPipe(rawPort)) {
  port = rawPort; // pass the pipe string directly to listen()
} else {
  const parsed = Number.parseInt(rawPort, 10);
  port = Number.isFinite(parsed) && parsed > 0 && parsed < 65536 ? parsed : 5000;
}
app.use("/api", roomRoutes);
app.use("/api", bookingRoutes);
app.use("/api", userRoutes);

app.listen(port, () => console.log(`Server running on port ${port}`));
