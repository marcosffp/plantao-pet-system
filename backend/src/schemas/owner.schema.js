'use strict';

const { z } = require('zod');

const registerOwnerSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  phone: z.string().min(10, 'Telefone inválido').max(15),
  address: z.string().min(5, 'Endereço deve ter pelo menos 5 caracteres'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres'),
});

const loginSchema = z.object({
  phone: z.string().min(10, 'Telefone inválido'),
  password: z.string().min(1, 'Senha é obrigatória'),
});

module.exports = { registerOwnerSchema, loginSchema };
