const express = require('express');
const router = express.Router();
const Grievance = require('../models/Grievance');
const auth = require('../controllers/auth'); 

router.post('/', auth, async (req, res) => {
  try {
    const { title, location, description, category, comments } = req.body;

    const grievance = new Grievance({
      user: req.user._id,
      title,
      location,
      description,
      category,
      comments: comments || [], 
    });

    await grievance.save();
    res.status(201).json(grievance);
  } catch (error) {
    res.status(500).json({ error: 'Server Error', message: error.message });
  }
});


router.get('/', async (req, res) => {
  try {
    const grievances = await Grievance.find()
    .populate("user", "username firstName lastName email")
    .sort({ createdAt: -1 });
    res.json(grievances);
  } catch (error) {
    res.status(500).json({ error: 'Server Error', message: error.message });
  }
});

router.put('/:id/upvote', auth, async (req, res) => {
  try {
    const grievance = await Grievance.findById(req.params.id);
    if (!grievance) return res.status(404).json({ error: 'Grievance not found' });

    grievance.upvotes += 1;
    await grievance.save();
    res.json(grievance);
  } catch (error) {
    res.status(500).json({ error: 'Server Error', message: error.message });
  }
});

router.put('/:id/downvote', auth, async (req, res) => {
  try {
    const grievance = await Grievance.findById(req.params.id);
    if (!grievance) return res.status(404).json({ error: 'Grievance not found' });

    grievance.downvotes += 1; // Increment the downvotes count
    await grievance.save();
    res.json(grievance);
  } catch (error) {
    res.status(500).json({ error: 'Server Error', message: error.message });
  }
});

module.exports = router;
