'use strict';

const { z } = require('zod');

const createPetSchema = z.object({
  name: z.string().min(1, 'Nome do pet é obrigatório').max(10, 'Nome do pet deve ter no máximo 10 caracteres'),
  species: z.enum(['DOG', 'CAT', 'OTHER']),
  breed: z.string().min(1, 'Raça é obrigatória'),
  age: z.number().int().min(0, 'Idade não pode ser negativa').max(30, 'Idade parece inválida'),
  specialNotes: z.string().nullable().optional(),
});

const updatePetSchema = z.object({
  name: z.string().min(1, 'Nome do pet é obrigatório').max(10, 'Nome do pet deve ter no máximo 10 caracteres').optional(),
  species: z.enum(['DOG', 'CAT', 'OTHER']).optional(),
  breed: z.string().min(1, 'Raça é obrigatória').optional(),
  age: z.number().int().min(0, 'Idade não pode ser negativa').max(30, 'Idade parece inválida').optional(),
  specialNotes: z.string().nullable().optional(),
});

module.exports = { createPetSchema, updatePetSchema };
