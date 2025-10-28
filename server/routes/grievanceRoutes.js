const express = require('express');
const router = express.Router();
const uuidv4 = require('../utils/uuid');
const Grievance = require('../models/Grievance');
const auth = require('../controllers/auth'); 
const { addGrievance } = require('../controllers/addGrievance');


router.post('/', auth, async (req, res) => {
  try {
    const { title, location, description, category, comments } = req.body;

    const grievance = new Grievance({
      grievanceId: uuidv4(), 
      userId: req.user.uuid || req.user.id || uuidv4(), 
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

// Get all grievances
router.get('/', async (req, res) => {
  try {
    const grievances = await Grievance.find()
      .sort({ createdAt: -1 });
    res.json(grievances);
  } catch (error) {
    res.status(500).json({ error: 'Server Error', message: error.message });
  }
});

router.put('/:id/upvote', auth, async (req, res) => {
  try {
    const grievance = await Grievance.findOne({ grievanceId: req.params.id });
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
    const grievance = await Grievance.findOne({ grievanceId: req.params.id });
    if (!grievance) return res.status(404).json({ error: 'Grievance not found' });

    grievance.downvotes += 1;
    await grievance.save();
    res.json(grievance);
  } catch (error) {
    res.status(500).json({ error: 'Server Error', message: error.message });
  }
});

router.post('/addgrievance', addGrievance);

module.exports = router;
