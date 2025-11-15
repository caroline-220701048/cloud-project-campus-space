import express from "express";
import {
  createBooking,
  approveBooking,
  rejectBooking,
  getCurrentBookings,
  getPreviousBookings
} from "../controllers/bookingController.js";

const router = express.Router();

router.post("/bookroom", createBooking);
router.put("/bookings/:id/approve", approveBooking);
router.put("/bookings/:id/reject", rejectBooking);

router.get("/bookings/current", getCurrentBookings);
router.get("/bookings/previous", getPreviousBookings);

export default router;
