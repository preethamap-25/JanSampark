const Grievance = require('../models/Grievance');
const User = require('../models/user');

exports.addGrievance = async (req, res) => {
  try {
    const {
      title,
      description,
      category,
      location,
      media,
      userId, // <- UUID from frontend
    } = req.body;

    if (!title || !description || !category || !userId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const user = await User.findOne({ userId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const grievance = new Grievance({
      userId: req.user.uuid,
      title,
      description,
      category,
      location: location || '',
      media: media || [],
      userId: user.userId,
    });

    await grievance.save();

    res.status(201).json({
      message: 'Grievance submitted successfully',
      grievance,
    });
  } catch (error) {
    console.error('Error adding grievance:', error);
    res.status(500).json({ error: 'Failed to submit grievance' });
  }
};


exports.getGrievanceById = async (req, res) => {
  try {
    const grievanceId = req.params.id;
    const grievance = await Grievance.findOne({ grievanceId });

    if (!grievance) {
      return res.status(404).json({ error: 'Grievance not found' });
    }
  }
  catch (error) {
    console.error('Error fetching grievance by ID:', error);
    res.status(500).json({ error: 'Failed to fetch grievance' });
  } 
}; 