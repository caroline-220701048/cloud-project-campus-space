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
const rawPort = process.env.PORT

app.use("/api", roomRoutes);
app.use("/api", bookingRoutes);
app.use("/api", userRoutes);

app.listen(rawPort, () => console.log(`Server running on port ${rawPort}`));
