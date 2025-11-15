import { db } from "../firebase.js";
import admin from "firebase-admin";

// POST /api/bookroom
// POST /api/bookroom
export const createBooking = async (req, res) => {
  try {
    const data = req.body;

    const ref = await db.collection("bookings").add({
      ...data,
      fromDate: admin.firestore.Timestamp.fromDate(new Date(data.fromDate)),
      toDate: admin.firestore.Timestamp.fromDate(new Date(data.toDate)),
      status: "pending",
      requestedAt: admin.firestore.Timestamp.now()
    });

    res.json({ success: true, bookingId: ref.id });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// PUT /api/bookings/:id/approve
export const approveBooking = async (req, res) => {
  try {
    await db.collection("bookings").doc(req.params.id).update({
      status: "approved"
    });

    res.json({ success: true, message: "Booking approved" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// PUT /api/bookings/:id/reject
export const rejectBooking = async (req, res) => {
  try {
    await db.collection("bookings").doc(req.params.id).update({
      status: "rejected"
    });

    res.json({ success: true, message: "Booking rejected" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// GET /api/bookings/current?userId=
export const getCurrentBookings = async (req, res) => {
  try {
    const userId = req.query.userId;

    const snapshot = await db.collection("bookings")
      .where("userId", "==", userId)
      .where("toDate", ">", admin.firestore.Timestamp.now())
      .get();

    const bookings = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(bookings);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// GET /api/bookings/previous?userId=
export const getPreviousBookings = async (req, res) => {
  try {
    const userId = req.query.userId;

    const snapshot = await db.collection("bookings")
      .where("userId", "==", userId)
      .where("toDate", "<", admin.firestore.Timestamp.now())
      .get();

    const bookings = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(bookings);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
