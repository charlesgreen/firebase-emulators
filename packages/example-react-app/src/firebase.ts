import { initializeApp } from 'firebase/app';
import { getAuth, connectAuthEmulator } from 'firebase/auth';
import { getFirestore, connectFirestoreEmulator } from 'firebase/firestore';
import { getStorage, connectStorageEmulator } from 'firebase/storage';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || 'demo-api-key',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || 'demo-project.firebaseapp.com',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || 'demo-project',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || 'demo-project.appspot.com',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '123456789',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || 'demo-app-id'
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Connect to emulators in development
if (import.meta.env.DEV || import.meta.env.VITE_USE_FIREBASE_EMULATOR === 'true') {
  console.log('🔥 Connecting to Firebase Emulators...');
  
  // Connect Auth emulator
  connectAuthEmulator(auth, 'http://localhost:5171', { disableWarnings: true });
  
  // Connect Firestore emulator
  connectFirestoreEmulator(db, 'localhost', 5172);
  
  // Connect Storage emulator
  connectStorageEmulator(storage, 'localhost', 5175);
  
  console.log('✅ Firebase Emulators connected');
  console.log('📊 Emulator UI: http://localhost:5179');
}

export default app;