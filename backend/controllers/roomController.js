import { db } from "../firebase.js";
import admin from "firebase-admin";

// GET /api/availableRooms?start=...&end=...
export const getAvailableRooms = async (req, res) => {
  try {
    const { start, end } = req.query;

    const startDate = new Date(start);
    const endDate = new Date(end);

    const roomsSnapshot = await db.collection("rooms").get();
    const allRooms = roomsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    const bookingsSnapshot = await db.collection("bookings")
      .where("status", "==", "approved")
      .get();

    const bookedRooms = [];

    bookingsSnapshot.forEach(doc => {
      const booking = doc.data();

      // Convert Firestore Timestamp or string → Date
      const bookingFrom = booking.fromDate?.toDate
        ? booking.fromDate.toDate()
        : new Date(booking.fromDate);

      const bookingTo = booking.toDate?.toDate
        ? booking.toDate.toDate()
        : new Date(booking.toDate);

      const hasConflict = !(endDate <= bookingFrom || startDate >= bookingTo);

      if (hasConflict) bookedRooms.push(booking.roomId);
    });

    const availableRooms = allRooms.filter(room => !bookedRooms.includes(room.id));

    res.json(availableRooms);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// GET /api/rooms
export const getAllRooms = async (req, res) => {
  try {
    const snapshot = await db.collection("rooms").get();
    const rooms = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(rooms);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// POST /api/rooms  (ADMIN ONLY)
export const createRoom = async (req, res) => {
  try {
    const room = req.body;

    const ref = await db.collection("rooms").add({
      ...room,
      createdAt: admin.firestore.Timestamp.now()
    });

    res.json({ success: true, id: ref.id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
