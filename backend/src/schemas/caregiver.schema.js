'use strict';

const { z } = require('zod');

const ServiceTypeEnum = z.enum(['WALK_30MIN', 'WALK_1H', 'HOME_VISIT', 'HOSTING']);
const CaregiverStatusEnum = z.enum(['ACTIVE', 'INACTIVE']);

const registerCaregiverSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  phone: z.string().min(10, 'Telefone inválido').max(15),
  neighborhoods: z.array(z.string()).min(1, 'Informe pelo menos um bairro atendido'),
  services: z.array(ServiceTypeEnum).min(1, 'Informe pelo menos um tipo de serviço'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres'),
});

const loginCaregiverSchema = z.object({
  phone: z.string().min(10, 'Telefone inválido'),
  password: z.string().min(1, 'Senha é obrigatória'),
});

const updateStatusSchema = z.object({
  status: CaregiverStatusEnum,
});

module.exports = { registerCaregiverSchema, loginCaregiverSchema, updateStatusSchema };
