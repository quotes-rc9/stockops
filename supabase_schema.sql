-- ═══════════════════════════════════════════════════════════════
-- StockOps — Esquema Supabase (migração do Firebase Firestore)
-- ═══════════════════════════════════════════════════════════════
-- Modelo: cada COLEÇÃO do Firestore vira uma TABELA com (id text + data jsonb).
-- O objeto inteiro do documento fica na coluna `data` — assim o app quase não
-- muda, só a camada de conexão.
--
-- Como aplicar: Supabase → SQL Editor → cole tudo → RUN.
-- Pode rodar mais de uma vez sem problema (é idempotente).
-- ═══════════════════════════════════════════════════════════════

create table if not exists produtos      (id text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists movimentacoes (id text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists solicitacoes  (id text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists pedidos        (id text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists auditoria     (id text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists maquinas      (id text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists config        (id text primary key, data jsonb not null, updated_at timestamptz default now());

-- Acesso público (mesmo comportamento das regras abertas atuais do Firestore).
-- ATENÇÃO: qualquer um com a chave anon pode ler/gravar — igual hoje no Firestore.
-- Para endurecer depois: ative autenticação do Supabase e troque as policies.
do $$
declare
  t text;
  tabelas text[] := array['produtos','movimentacoes','solicitacoes','pedidos','auditoria','maquinas','config'];
begin
  foreach t in array tabelas loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists public_all on %I;', t);
    execute format('create policy public_all on %I for all using (true) with check (true);', t);
    -- adiciona ao realtime (ignora se já estiver na publicação)
    begin
      execute format('alter publication supabase_realtime add table %I;', t);
    exception when others then null;
    end;
  end loop;
end $$;
