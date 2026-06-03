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

const update = asyncHandler(async (req, res) => {
  const data = await petsService.update(req.params.petId, req.body, req.user);
  res.status(200).json({ data });
});

const remove = asyncHandler(async (req, res) => {
  await petsService.remove(req.params.petId, req.user);
  res.status(204).send();
});

module.exports = { create, findMine, findById, update, remove };
