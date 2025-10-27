const User = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

// Register controller
exports.register = async (req, res) => {
  const {
    email,
    username,
    password,
    firstName,
    lastName,
    aadhar,
    phone,
    pincode,
    voterId
  } = req.body;

  if (!email || !username || !password || !firstName || !lastName || !aadhar || !phone || !pincode || !voterId) {
    return res.status(400).json({ msg: 'All fields are required' });
  }

  try {
    // Check for duplicate users
    let existingUser = await User.findOne({
      $or: [{ email }, { username }, { aadhar }, { voterId }]
    });

    if (existingUser) {
      return res.status(400).json({ msg: 'User already exists with provided credentials' });
    }

    // Create new user with generated userID
    const user = new User({
      userID: uuidv4(), // Generate unique userID
      email,
      username,
      password,
      firstName,
      lastName,
      aadhar,
      phone,
      pincode,
      voterId,
    });

    // Hash password
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    // Save to DB
    await user.save();

    res.status(201).json({ msg: 'User registered successfully' });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ error: 'Server Error', message: err.message });
  }
};

// Login controller
exports.login = async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password are required' });
  }

  try {
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // The same userID will be fetched here for every login attempt
    const payload = {
      userID: user.userID,     // Include userID in JWT
      username: user.username
    };
    
    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '1h' }, // Token expires in 1 hour
      (err, token) => {
        if (err) throw err;
        res.json({ token, msg: 'Login successful' });
      }
    );
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Server Error', message: err.message });
  }
};
