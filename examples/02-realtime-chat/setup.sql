-- Run this in Supabase SQL Editor to enable real-time chat
-- Dashboard: https://supabase.com/dashboard/project/aayokobrxxndsrcsmzcg/sql

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous read" ON messages FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous insert" ON messages FOR INSERT TO anon WITH CHECK (true);

ALTER PUBLICATION supabase_realtime ADD TABLE messages;
