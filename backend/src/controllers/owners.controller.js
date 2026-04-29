'use strict';

const ownersService = require('../services/owners.service');
const asyncHandler = require('../utils/asyncHandler');

const findById = asyncHandler(async (req, res) => {
  const data = await ownersService.findById(req.params.id);
  res.status(200).json({ data });
});

module.exports = { findById };
