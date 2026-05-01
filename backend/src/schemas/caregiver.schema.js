'use strict';

const { z } = require('zod');

const ServiceTypeEnum = z.enum(['WALK_30MIN', 'WALK_1H', 'HOME_VISIT', 'HOSTING']);
const CaregiverStatusEnum = z.enum(['ACTIVE', 'INACTIVE']);

const registerCaregiverSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres').max(100, 'Nome deve ter no máximo 100 caracteres'),
  email: z.string().email('Email inválido'),
  phone: z.string().min(10, 'Telefone inválido').max(15, 'Telefone inválido'),
  neighborhoods: z.array(z.string()).min(1, 'Informe pelo menos um bairro atendido').max(5, 'Informe no máximo 5 bairros'),
  services: z.array(ServiceTypeEnum).min(1, 'Informe pelo menos um tipo de serviço').max(4, 'Informe no máximo 4 tipos'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres'),
});

const loginCaregiverSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(1, 'Senha é obrigatória'),
});

const updateStatusSchema = z.object({
  status: CaregiverStatusEnum,
});

module.exports = { registerCaregiverSchema, loginCaregiverSchema, updateStatusSchema };
