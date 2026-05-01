'use strict';

const caregiversService = require('../services/caregivers.service');
const asyncHandler = require('../utils/asyncHandler');

const findAll = asyncHandler(async (req, res) => {
  const data = await caregiversService.findAll();
  res.status(200).json({ data });
});

const findById = asyncHandler(async (req, res) => {
  const data = await caregiversService.findById(req.params.id);
  res.status(200).json({ data });
});

const updateStatus = asyncHandler(async (req, res) => {
  const data = await caregiversService.updateStatus(req.body.status, req.user);
  res.status(200).json({ data });
});

const findReviews = asyncHandler(async (req, res) => {
  const data = await caregiversService.findReviews(req.params.id);
  res.status(200).json({ data });
});

module.exports = { findAll, findById, updateStatus, findReviews };
