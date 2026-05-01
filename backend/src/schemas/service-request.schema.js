'use strict';

const { z } = require('zod');

const createServiceRequestSchema = z.object({
  petId: z.string().uuid('petId deve ser um UUID válido'),
  serviceType: z.enum(['WALK_30MIN', 'WALK_1H', 'HOME_VISIT', 'HOSTING']),
  scheduledAt: z.string().datetime('scheduledAt deve ser uma data/hora válida no formato ISO 8601'),
  meetingAddress: z.string().min(5, 'Endereço de encontro é obrigatório').max(200, 'Endereço de encontro deve ter no máximo 200 caracteres'),
});

module.exports = { createServiceRequestSchema };
