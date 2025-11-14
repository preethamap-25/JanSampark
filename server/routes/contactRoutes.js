// server.js
const express = require('express');
const router = express.Router();
const cron = require('node-cron');
const Official = require('../models/Official');
// const { fetchAndUpdateContacts } = require('./updater');

router.get("/", async (req, res) => {
  const contacts = await Official.find();
  res.json(contacts); 
});

// Background task to update contacts every day at midnight
// cron.schedule('0 0 * * *', async () => {
//   await fetchAndUpdateContacts();
//   console.log('Contact list refreshed!');
// });
