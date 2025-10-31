-- ================================================
-- SCRIPT DDL - CHECKPOINT DEVOPS 3º SEMESTRE
-- Autor: Pedro Ladeira - RM558514
-- Professor: João Menk
-- Data: 31/10/2025
-- ================================================

-- Database: PostgreSQL Azure
-- Tabelas: user, role, user_role (relacionamento many-to-many)

-- ================================================
-- 1. TABELA USER (Usuários do sistema)
-- ================================================
CREATE TABLE IF NOT EXISTS "user" (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT true,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_access TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 2. TABELA ROLE (Perfis/Permissões do sistema)
-- ================================================
CREATE TABLE IF NOT EXISTS "role" (
    id BIGSERIAL PRIMARY KEY,
    authority VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(500),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 3. TABELA USER_ROLE (Relacionamento Many-to-Many)
-- ================================================
CREATE TABLE IF NOT EXISTS user_role (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role_user 
        FOREIGN KEY (user_id) REFERENCES "user"(id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_user_role_role 
        FOREIGN KEY (role_id) REFERENCES "role"(id) 
        ON DELETE CASCADE
);

-- ================================================
-- 4. TABELA REFRESH_TOKEN (Controle JWT)
-- ================================================
CREATE TABLE IF NOT EXISTS refresh_token (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(500) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refresh_token_user 
        FOREIGN KEY (user_id) REFERENCES "user"(id) 
        ON DELETE CASCADE
);

-- ================================================
-- 5. TABELA RECOVERY (Recuperação de senha)
-- ================================================
CREATE TABLE IF NOT EXISTS recovery (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- 6. DADOS INICIAIS (SEED DATA)
-- ================================================

-- Inserir roles padrão do sistema
INSERT INTO "role" (authority, description) VALUES 
    ('ROLE_USER', 'Usuário padrão do sistema'),
    ('ROLE_ADMIN', 'Administrador do sistema'),
    ('ROLE_MODERATOR', 'Moderador do sistema')
ON CONFLICT (authority) DO NOTHING;

-- ================================================
-- 7. ÍNDICES PARA PERFORMANCE
-- ================================================

-- Índice para busca por email (login)
CREATE INDEX IF NOT EXISTS idx_user_email ON "user"(email);

-- Índice para busca por token refresh
CREATE INDEX IF NOT EXISTS idx_refresh_token ON refresh_token(token);

-- Índice para recuperação por email
CREATE INDEX IF NOT EXISTS idx_recovery_email ON recovery(email);

-- Índice para user_role (queries frequentes)
CREATE INDEX IF NOT EXISTS idx_user_role_user_id ON user_role(user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_role_id ON user_role(role_id);

-- ================================================
-- 8. COMENTÁRIOS NAS TABELAS
-- ================================================

COMMENT ON TABLE "user" IS 'Tabela principal de usuários do sistema';
COMMENT ON TABLE "role" IS 'Tabela de perfis e permissões';
COMMENT ON TABLE user_role IS 'Relacionamento many-to-many entre users e roles';
COMMENT ON TABLE refresh_token IS 'Controle de tokens JWT para refresh';
COMMENT ON TABLE recovery IS 'Códigos de recuperação de senha';

-- ================================================
-- FIM DO SCRIPT DDL
-- ================================================
