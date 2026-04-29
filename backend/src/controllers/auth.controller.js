'use strict';

const authService = require('../services/auth.service');
const asyncHandler = require('../utils/asyncHandler');

const registerOwner = asyncHandler(async (req, res) => {
  const data = await authService.registerOwner(req.body);
  res.status(201).json({ data });
});

const loginOwner = asyncHandler(async (req, res) => {
  const data = await authService.loginOwner(req.body);
  res.status(200).json(data);
});

const registerCaregiver = asyncHandler(async (req, res) => {
  const data = await authService.registerCaregiver(req.body);
  res.status(201).json({ data });
});

const loginCaregiver = asyncHandler(async (req, res) => {
  const data = await authService.loginCaregiver(req.body);
  res.status(200).json(data);
});

module.exports = { registerOwner, loginOwner, registerCaregiver, loginCaregiver };
