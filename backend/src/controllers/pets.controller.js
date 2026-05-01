'use strict';

const petsService = require('../services/pets.service');
const asyncHandler = require('../utils/asyncHandler');

const create = asyncHandler(async (req, res) => {
  const data = await petsService.create(req.body, req.user);
  res.status(201).json({ data });
});

const findMine = asyncHandler(async (req, res) => {
  const data = await petsService.findByOwnerId(req.user.id);
  res.status(200).json({ data });
});

const findById = asyncHandler(async (req, res) => {
  const data = await petsService.findById(req.params.id);
  res.status(200).json({ data });
});

module.exports = { create, findMine, findById };
