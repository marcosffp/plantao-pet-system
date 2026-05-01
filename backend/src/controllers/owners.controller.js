'use strict';

const ownersService = require('../services/owners.service');
const asyncHandler = require('../utils/asyncHandler');

const getMe = asyncHandler(async (req, res) => {
  const data = await ownersService.findById(req.user.id);
  res.status(200).json({ data });
});

module.exports = { getMe };
