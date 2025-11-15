import express from "express";
import {
  getAllRooms,
  createRoom,
  getAvailableRooms
} from "../controllers/roomController.js";

const router = express.Router();

router.get("/rooms", getAllRooms);
router.post("/rooms", createRoom);
router.get("/availableRooms", getAvailableRooms);

export default router;
