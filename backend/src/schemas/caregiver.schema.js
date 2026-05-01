'use strict';

const { z } = require('zod');

const ServiceTypeEnum = z.enum(['WALK_30MIN', 'WALK_1H', 'HOME_VISIT', 'HOSTING']);
const CaregiverStatusEnum = z.enum(['ACTIVE', 'INACTIVE']);

const registerCaregiverSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres').max(100, 'Nome deve ter no máximo 100 caracteres'),
  phone: z.string().min(10, 'Telefone inválido').max(15, 'Telefone inválido'),
  neighborhoods: z.array(z.string()).min(1, 'Informe pelo menos um bairro atendido').max(5, 'Informe no máximo 5 bairros atendidos'),
  services: z.array(ServiceTypeEnum).min(1, 'Informe pelo menos um tipo de serviço').max(4, 'Informe no máximo 4 tipos de serviço'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres').max(6, 'Senha deve ter no máximo 6 caracteres'),
});

const loginCaregiverSchema = z.object({
  phone: z.string().min(10, 'Telefone inválido').max(15, 'Telefone inválido'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres').max(6, 'Senha deve ter no máximo 6 caracteres'),
});

const updateStatusSchema = z.object({
  status: CaregiverStatusEnum,
});

module.exports = { registerCaregiverSchema, loginCaregiverSchema, updateStatusSchema };
