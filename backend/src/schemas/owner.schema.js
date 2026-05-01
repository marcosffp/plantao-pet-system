'use strict';

const { z } = require('zod');

const registerOwnerSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres').max(100, 'Nome deve ter no máximo 100 caracteres'),
  phone: z.string().min(10, 'Telefone inválido').max(15, 'Telefone inválido'),
  address: z.string().min(5, 'Endereço deve ter pelo menos 5 caracteres').max(200, 'Endereço deve ter no máximo 200 caracteres'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres').max(6, 'Senha deve ter no máximo 6 caracteres'),
});

const loginSchema = z.object({
  phone: z.string().min(10, 'Telefone inválido').max(15, 'Telefone inválido'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres').max(6, 'Senha deve ter no máximo 6 caracteres'),
});

module.exports = { registerOwnerSchema, loginSchema };
