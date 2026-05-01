'use strict';

const { z } = require('zod');

const createReviewSchema = z.object({
  serviceRequestId: z.string().uuid('serviceRequestId deve ser um UUID válido'),
  rating: z.number().int().min(1, 'Nota mínima é 1').max(5, 'Nota máxima é 5'),
  comment: z.string().min(1, 'Comentário é obrigatório').max(500, 'Comentário deve ter no máximo 500 caracteres'),
});

module.exports = { createReviewSchema };
