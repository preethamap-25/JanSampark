// models/Official.js
const mongoose = require("mongoose");

const OfficialSchema = new mongoose.Schema({
  role: String,
  name: String,
  party: String,
  start_date: String,
  constituency: String,
  social: {
    twitter: String,
    instagram: String,
    website: String,
    email: String
  }
});

module.exports = mongoose.model("Official", OfficialSchema);
