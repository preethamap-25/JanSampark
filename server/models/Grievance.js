const mongoose = require('mongoose');

const GrievanceSchema = new mongoose.Schema({
  grievanceID: {
    type: String,
    unique: true,
    default: () => new mongoose.Types.ObjectId() 
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
  media: [String],

  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Grievance', GrievanceSchema);
