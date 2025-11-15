// firebase.js (ES module)
import admin from "firebase-admin";
import fs from "fs/promises";
import path from "path";

let serviceAccount;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  // Production / Azure: read JSON from App Setting
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    console.log("Loaded Firebase service account from environment variable.");
  } catch (err) {
    console.error("FATAL: FIREBASE_SERVICE_ACCOUNT is not valid JSON.", err);
    throw err;
  }
} else {
  // Local development: load serviceAccountKey.json from disk (gitignored)
  const localPath = path.resolve(process.cwd(), "serviceAccountKey.json");
  try {
    const raw = await fs.readFile(localPath, "utf8");
    serviceAccount = JSON.parse(raw);
    console.log('Loaded Firebase service account from ${localPath});
  } catch (err) {
    console.error(
      `Could not load local serviceAccountKey.json at ${localPath}. ` +
      If running in Azure, set FIREBASE_SERVICE_ACCOUNT app setting with the JSON content.,
      err
    );
    throw err;
  }
}

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const db = admin.firestore();
export default admin;