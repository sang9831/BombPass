CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname varchar(40) NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE user_auth_providers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider varchar(20) NOT NULL CHECK (provider IN ('LOCAL','GOOGLE','KAKAO')),
  provider_subject varchar(255) NOT NULL,
  password_hash varchar(255),
  linked_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_subject),
  CHECK ((provider = 'LOCAL' AND password_hash IS NOT NULL) OR (provider <> 'LOCAL' AND password_hash IS NULL))
);
CREATE INDEX idx_user_auth_providers_user ON user_auth_providers(user_id);
CREATE TABLE game_rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code varchar(12) NOT NULL UNIQUE,
  host_user_id uuid NOT NULL REFERENCES users(id),
  status varchar(20) NOT NULL DEFAULT 'WAITING' CHECK (status IN ('WAITING','PLAYING','FINISHED','CANCELLED')),
  started_at timestamptz,
  ended_at timestamptz
);
CREATE TABLE game_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES game_rooms(id),
  user_id uuid NOT NULL REFERENCES users(id),
  elimination_order integer,
  final_rank integer,
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (room_id,user_id)
);
CREATE INDEX idx_game_participants_user_room ON game_participants(user_id,room_id);
CREATE TABLE game_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL UNIQUE REFERENCES game_rooms(id),
  winner_user_id uuid REFERENCES users(id),
  finished_at timestamptz NOT NULL DEFAULT now(),
  result_version integer NOT NULL DEFAULT 1
);
CREATE TABLE user_stats (
  user_id uuid PRIMARY KEY REFERENCES users(id),
  wins integer NOT NULL DEFAULT 0,
  losses integer NOT NULL DEFAULT 0,
  score bigint NOT NULL DEFAULT 0,
  version bigint NOT NULL DEFAULT 0
);
CREATE TABLE reward_ledger (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES game_rooms(id),
  user_id uuid NOT NULL REFERENCES users(id),
  reward_type varchar(40) NOT NULL,
  amount bigint NOT NULL,
  idempotency_key varchar(255) NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
