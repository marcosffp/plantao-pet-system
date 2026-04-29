'use strict';

const serviceRequestsService = require('../services/service-requests.service');
const asyncHandler = require('../utils/asyncHandler');

const create = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.create(req.body, req.user);
  res.status(201).json({ data });
});

const findOpen = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.findOpen();
  res.status(200).json({ data });
});

const findMine = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.findMine(req.user);
  res.status(200).json({ data });
});

const findById = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.findById(req.params.id);
  res.status(200).json({ data });
});

const accept = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.accept(req.params.id, req.user);
  res.status(200).json({ data });
});

const refuse = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.refuse(req.params.id, req.user);
  res.status(200).json({ data });
});

const cancel = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.cancel(req.params.id, req.user);
  res.status(200).json({ data });
});

const start = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.start(req.params.id, req.user);
  res.status(200).json({ data });
});

const complete = asyncHandler(async (req, res) => {
  const data = await serviceRequestsService.complete(req.params.id, req.user);
  res.status(200).json({ data });
});

module.exports = { create, findOpen, findMine, findById, accept, refuse, cancel, start, complete };
