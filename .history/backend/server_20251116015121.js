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
const rawPort = process.env.PORT ?? process.env.WEBSITE_PORT ?? process.env.PORT_NUMBER ?? '4000';
const parsed = Number.parseInt(rawPort, 10);
const port = Number.isFinite(parsed) && parsed > 0 && parsed < 65536 ? parsed : 5000;
app.use("/api", roomRoutes);
app.use("/api", bookingRoutes);
app.use("/api", userRoutes);

app.listen(Port, () => console.log(`Server running on port ${rawPort}`));
