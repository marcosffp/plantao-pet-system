'use strict';

const reviewsService = require('../services/reviews.service');
const asyncHandler = require('../utils/asyncHandler');

const create = asyncHandler(async (req, res) => {
  const data = await reviewsService.create(req.body, req.user);
  res.status(201).json({ data });
});

module.exports = { create };
