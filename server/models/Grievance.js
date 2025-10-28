const mongoose = require('mongoose');
const uuidv4 = require('../utils/uuid'); 

const GrievanceSchema = new mongoose.Schema({
  grievanceID: {
    type: String,
    unique: true,
    default: uuidv4, 
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  location: {
    type: String,
  },
  media: {
    type: [String],
    default: [],
  },

  // 👇 User is linked by their UUID instead of ObjectId
  userId: {
    type: String,
    required: true,
    ref: 'User', 
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Grievance', GrievanceSchema);
