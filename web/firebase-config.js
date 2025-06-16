// Configuration Firebase pour le web
const firebaseConfig = {
  apiKey: "AIzaSyBbQ_HKis3dwaUFodvNpfNr7EcFcpk4ZLc",
  authDomain: "regulation-459709.firebaseapp.com",
  projectId: "regulation-459709",
  storageBucket: "regulation-459709.firebasestorage.app",
  messagingSenderId: "1017446732688",
  appId: "1:1017446732688:web:6b51c8d14840837e875915",
  measurementId: "G-2E9P3JFC87"
};

// Initialisation de Firebase
firebase.initializeApp(firebaseConfig);

// Configuration du service worker pour les notifications
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/firebase-messaging-sw.js')
    .then(function(registration) {
      console.log('Service Worker enregistré avec succès:', registration);
    })
    .catch(function(error) {
      console.log('Erreur lors de l\'enregistrement du Service Worker:', error);
    });
} 