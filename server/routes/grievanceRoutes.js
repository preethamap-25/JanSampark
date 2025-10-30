const express = require('express');
const router = express.Router();
const uuidv4 = require('../utils/uuid');
const Grievance = require('../models/Grievance');
const auth = require('../middleware/auth'); 
const { addGrievance } = require('../controllers/grievanceController');
const { getGrievanceById } = require('../controllers/grievanceController');
const upload = require('../config/multer');
// const { verifyToken } = require('../middleware/auth');


router.post('/', auth, upload.array('media', 5), async (req, res) => {
  try {
    const mediaFiles = req.files.map((file) => {
      return `${req.protocol}://${req.get('host')}/uploads/${file.filename}`;
    });

    const grievance = new Grievance({
      title: req.body.title,
      description: req.body.description,
      category: req.body.category,
      location: req.body.location,
      media: mediaFiles, // store URLs
      userId: req.user.userId,
    });

    await grievance.save();
    res.status(201).json({ message: 'Grievance submitted successfully', grievance });
    console.log('Grievance submitted:', grievance);
  } catch (error) {
    console.error('Error submitting grievance:', error);
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
router.get('/addgrievance/:id', getGrievanceById);

module.exports = router;
