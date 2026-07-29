-- Run this in Supabase SQL Editor to enable Kanban board
-- Dashboard: https://supabase.com/dashboard/project/aayokobrxxndsrcsmzcg/sql

CREATE TABLE IF NOT EXISTS kanban_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  priority TEXT DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High')),
  "column" TEXT NOT NULL DEFAULT 'Backlog' CHECK ("column" IN ('Backlog', 'In Progress', 'Review', 'Done')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  position INTEGER DEFAULT 0
);

ALTER TABLE kanban_cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous read" ON kanban_cards FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous insert" ON kanban_cards FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Allow anonymous update" ON kanban_cards FOR UPDATE TO anon USING (true);
CREATE POLICY "Allow anonymous delete" ON kanban_cards FOR DELETE TO anon USING (true);
