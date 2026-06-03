'use strict';

const { z } = require('zod');

const createPetSchema = z.object({
  name: z.string().min(1, 'Nome do pet é obrigatório').max(10, 'Nome do pet deve ter no máximo 10 caracteres'),
  species: z.enum(['DOG', 'CAT', 'OTHER']),
  breed: z.string().min(1, 'Raça é obrigatória'),
  age: z.number().int().min(0, 'Idade não pode ser negativa').max(30, 'Idade parece inválida'),
  specialNotes: z.string().optional(),
});

const updatePetSchema = createPetSchema.partial();

module.exports = { createPetSchema, updatePetSchema };
