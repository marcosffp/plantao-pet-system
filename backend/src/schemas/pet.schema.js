'use strict';

const { z } = require('zod');

const createPetSchema = z.object({
  name: z.string().min(1, 'Nome do pet é obrigatório'),
  species: z.enum(['DOG', 'CAT', 'OTHER']),
  breed: z.string().min(1, 'Raça é obrigatória'),
  age: z.number().int().min(0, 'Idade não pode ser negativa'),
  specialNotes: z.string().optional(),
});

module.exports = { createPetSchema };
