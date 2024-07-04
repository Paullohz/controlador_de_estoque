const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
require('dotenv').config(); 

let serviceAccount;
try {
  serviceAccount = require('../config/serviceAccountKey.json'); 
} catch (error) {
  console.error('Error loading service account key:', error);
  process.exit(1); 
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL, 
});

const db = admin.firestore();
const app = express();
app.use(bodyParser.json());


db.collection('test').add({ test: 'test' })
  .then(() => console.log('Firebase connected successfully'))
  .catch(error => console.error('Firebase connection error:', error));

app.post('/add-product', async (req, res) => {
  const { icone, nome, sigla, preco } = req.body;
  try {
    const newProduct = await db.collection('products').add({ icone, nome, sigla, preco });
    res.status(201).send(`Product added with ID: ${newProduct.id}`);
  } catch (error) {
    res.status(400).send('Error adding product: ' + error.message);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
