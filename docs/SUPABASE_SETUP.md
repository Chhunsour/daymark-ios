# Supabase Backend Setup & Synchronization Architecture

This document defines the production PostgreSQL database schema, Row Level Security (RLS) policies, and synchronization architecture for **Daymark**.

Daymark uses an offline-first architecture via `DaymarkRepository`. On iOS, data is persisted locally and atomically in `Application Support/DaymarkData/`. When Supabase credentials (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) are configured, the repository synchronizes changes with Supabase Postgres.

---

## 1. Database Schema

Execute the following SQL in the Supabase SQL Editor:

```sql
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Projects Table
create table public.projects (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
    name text not null,
    description text,
    status text not null default 'active' check (status in ('active', 'paused', 'completed', 'archived')),
    color_hex text not null default '#3B82F6',
    icon_name text not null default 'briefcase.fill',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 2. Milestones Table
create table public.milestones (
    id uuid primary key default uuid_generate_v4(),
    project_id uuid references public.projects(id) on delete cascade not null,
    user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
    title text not null,
    target_outcome text,
    target_date date,
    is_completed boolean not null default false,
    completed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 3. Tasks Table
create table public.tasks (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
    project_id uuid references public.projects(id) on delete set null,
    milestone_id uuid references public.milestones(id) on delete set null,
    title text not null,
    notes text,
    importance text not null default 'medium' check (importance in ('low', 'medium', 'high', 'critical')),
    status text not null default 'inbox' check (status in ('inbox', 'planned', 'inProgress', 'paused', 'completed', 'cancelled')),
    is_daily_priority boolean not null default false,
    due_date timestamptz,
    scheduled_start_time timestamptz,
    scheduled_end_time timestamptz,
    estimated_duration_minutes integer not null default 30 check (estimated_duration_minutes > 0),
    recurrence_rule text,
    completed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 4. Routines Table
create table public.routines (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
    title text not null,
    description text,
    target_time text, -- e.g. "08:15"
    checklist_items jsonb not null default '[]'::jsonb,
    is_active boolean not null default true,
    completed_dates jsonb not null default '[]'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 5. User Schedule Profiles Table
create table public.schedule_profiles (
    user_id uuid primary key references auth.users(id) on delete cascade default auth.uid(),
    wake_up_hour integer not null default 8,
    wake_up_minute integer not null default 0,
    bedtime_hour integer not null default 24,
    bedtime_minute integer not null default 0,
    work_start_hour integer not null default 9,
    work_start_minute integer not null default 0,
    work_end_hour integer not null default 18,
    work_end_minute integer not null default 0,
    work_project_id uuid references public.projects(id) on delete set null,
    commute_buffer_minutes integer not null default 20,
    task_gap_buffer_minutes integer not null default 15,
    max_daily_priorities integer not null default 5,
    updated_at timestamptz not null default now()
);
```

---

## 2. Row Level Security (RLS) Policies

All tables enforce strict user isolation:

```sql
-- Enable RLS
alter table public.projects enable row level security;
alter table public.milestones enable row level security;
alter table public.tasks enable row level security;
alter table public.routines enable row level security;
alter table public.schedule_profiles enable row level security;

-- Projects Policy
create policy "Users can manage own projects"
    on public.projects for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Milestones Policy
create policy "Users can manage own milestones"
    on public.milestones for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Tasks Policy
create policy "Users can manage own tasks"
    on public.tasks for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Routines Policy
create policy "Users can manage own routines"
    on public.routines for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Schedule Profiles Policy
create policy "Users can manage own schedule profile"
    on public.schedule_profiles for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);
```

---

## 3. Performance Indexes & Automated Timestamps

```sql
-- Indexes
create index idx_tasks_user_status on public.tasks(user_id, status);
create index idx_tasks_user_due on public.tasks(user_id, due_date);
create index idx_tasks_user_scheduled on public.tasks(user_id, scheduled_start_time);
create index idx_milestones_project on public.milestones(project_id);

-- Auto-update updated_at timestamp function
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger tr_projects_updated_at before update on public.projects for each row execute procedure public.handle_updated_at();
create trigger tr_milestones_updated_at before update on public.milestones for each row execute procedure public.handle_updated_at();
create trigger tr_tasks_updated_at before update on public.tasks for each row execute procedure public.handle_updated_at();
create trigger tr_routines_updated_at before update on public.routines for each row execute procedure public.handle_updated_at();
create trigger tr_schedule_profiles_updated_at before update on public.schedule_profiles for each row execute procedure public.handle_updated_at();
```

---

## 4. Client iOS Configuration

In `Daymark/Core/Persistence/SupabaseConfig.swift`, configuration is dynamically loaded from the app bundle or environment variables:

```swift
public struct SupabaseConfig: Sendable {
    public static var isConfigured: Bool {
        url != nil && anonKey != nil
    }

    public static var url: URL? {
        if let str = ProcessInfo.processInfo.environment["SUPABASE_URL"], let url = URL(string: str) {
            return url
        }
        if let str = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String, let url = URL(string: str) {
            return url
        }
        return nil
    }

    public static var anonKey: String? {
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"], !key.isEmpty {
            return key
        }
        if let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String, !key.isEmpty {
            return key
        }
        return nil
    }
}
```

When configured, the app repository seamlessly bridges local JSON cache with Supabase Postgres REST endpoints, ensuring zero data loss and offline resilience.
