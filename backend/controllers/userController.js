import { db } from "../firebase.js";

export const getUser = async (req, res) => {
  try {
    const doc = await db.collection("users").doc(req.params.id).get();
    res.json({ id: doc.id, ...doc.data() });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
