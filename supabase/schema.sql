create extension if not exists pgcrypto;

create type public.event_role as enum ('owner', 'cohost', 'helper', 'guest');
create type public.event_preset as enum ('birthday', 'wedding', 'anniversary', 'graduation', 'holiday', 'reunion', 'custom');
create type public.responsibility_kind as enum ('setup', 'breakdown', 'meal', 'bar', 'decorations', 'music', 'activities', 'lodging', 'transportation', 'supplies');
create type public.work_status as enum ('not_started', 'in_progress', 'blocked', 'ready', 'done');
create type public.expense_category as enum ('meals', 'activities', 'lodging_venue', 'supplies', 'bar', 'decorations', 'music', 'transportation');
create type public.split_policy as enum ('equal', 'adults_only', 'assigned_users', 'owner_pays');
create type public.note_visibility as enum ('event_board', 'private_message', 'owner_only');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  phone text,
  email text,
  is_adult boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  preset public.event_preset not null default 'custom',
  age_group text not null default '',
  guest_count integer not null check (guest_count > 0),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  owner_id uuid not null references public.profiles(id) on delete restrict,
  default_split_policy public.split_policy not null default 'equal',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.event_members (
  event_id uuid not null references public.events(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role public.event_role not null default 'guest',
  can_receive_notifications boolean not null default true,
  joined_at timestamptz not null default now(),
  primary key (event_id, profile_id)
);

create table public.venues (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null unique references public.events(id) on delete cascade,
  name text not null,
  address text not null,
  arrival_window text not null default '',
  parking_notes text not null default '',
  latitude double precision,
  longitude double precision,
  updated_at timestamptz not null default now()
);

create table public.responsibilities (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  title text not null,
  kind public.responsibility_kind not null,
  owner_id uuid not null references public.profiles(id) on delete restrict,
  due_at timestamptz not null,
  status public.work_status not null default 'not_started',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.checklist_items (
  id uuid primary key default gen_random_uuid(),
  responsibility_id uuid not null references public.responsibilities(id) on delete cascade,
  title text not null,
  is_done boolean not null default false,
  position integer not null default 0
);

create table public.meals (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  title text not null,
  owner_id uuid not null references public.profiles(id) on delete restrict,
  serving_at timestamptz not null,
  guest_count integer not null check (guest_count > 0),
  notes text not null default '',
  estimated_cost numeric(12,2) not null default 0 check (estimated_cost >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.meal_items (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.meals(id) on delete cascade,
  name text not null,
  quantity numeric(12,2) not null check (quantity >= 0),
  unit text not null default 'count',
  item_type text not null check (item_type in ('ingredient', 'equipment')),
  is_packed boolean not null default false
);

create table public.supply_items (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  name text not null,
  quantity numeric(12,2) not null check (quantity >= 0),
  unit text not null default 'count',
  category public.responsibility_kind not null,
  assigned_profile_id uuid references public.profiles(id) on delete set null,
  is_packed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  title text not null,
  amount numeric(12,2) not null check (amount >= 0),
  category public.expense_category not null,
  paid_by_profile_id uuid not null references public.profiles(id) on delete restrict,
  split_policy public.split_policy not null,
  receipt_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.expense_splits (
  expense_id uuid not null references public.expenses(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  share_amount numeric(12,2) check (share_amount >= 0),
  primary key (expense_id, profile_id)
);

create table public.notes (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete restrict,
  visibility public.note_visibility not null default 'event_board',
  message text not null check (length(trim(message)) > 0),
  created_at timestamptz not null default now()
);

create table public.note_recipients (
  note_id uuid not null references public.notes(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  primary key (note_id, profile_id)
);

create table public.event_updates (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  actor_id uuid not null references public.profiles(id) on delete restrict,
  message text not null,
  created_at timestamptz not null default now()
);

create or replace function public.is_event_member(target_event_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.event_members
    where event_id = target_event_id
      and profile_id = (select auth.uid())
  );
$$;

create or replace function public.can_manage_event(target_event_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.event_members
    where event_id = target_event_id
      and profile_id = (select auth.uid())
      and role in ('owner', 'cohost')
  );
$$;

create or replace function public.is_event_owner(target_event_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.events
    where id = target_event_id
      and owner_id = (select auth.uid())
  );
$$;

create index events_owner_id_idx on public.events(owner_id);
create index event_members_profile_id_idx on public.event_members(profile_id);
create index venues_event_id_idx on public.venues(event_id);
create index responsibilities_event_id_idx on public.responsibilities(event_id);
create index responsibilities_owner_id_idx on public.responsibilities(owner_id);
create index checklist_items_responsibility_id_idx on public.checklist_items(responsibility_id);
create index meals_event_id_idx on public.meals(event_id);
create index meals_owner_id_idx on public.meals(owner_id);
create index meal_items_meal_id_idx on public.meal_items(meal_id);
create index supply_items_event_id_idx on public.supply_items(event_id);
create index supply_items_assigned_profile_id_idx on public.supply_items(assigned_profile_id);
create index expenses_event_id_idx on public.expenses(event_id);
create index expenses_paid_by_profile_id_idx on public.expenses(paid_by_profile_id);
create index expense_splits_profile_id_idx on public.expense_splits(profile_id);
create index notes_event_id_idx on public.notes(event_id);
create index notes_author_id_idx on public.notes(author_id);
create index note_recipients_profile_id_idx on public.note_recipients(profile_id);
create index event_updates_event_id_created_at_idx on public.event_updates(event_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.events enable row level security;
alter table public.event_members enable row level security;
alter table public.venues enable row level security;
alter table public.responsibilities enable row level security;
alter table public.checklist_items enable row level security;
alter table public.meals enable row level security;
alter table public.meal_items enable row level security;
alter table public.supply_items enable row level security;
alter table public.expenses enable row level security;
alter table public.expense_splits enable row level security;
alter table public.notes enable row level security;
alter table public.note_recipients enable row level security;
alter table public.event_updates enable row level security;

create policy profiles_select_self_or_event_member on public.profiles
  for select
  using (
    id = (select auth.uid())
    or exists (
      select 1
      from public.event_members mine
      join public.event_members theirs on theirs.event_id = mine.event_id
      where mine.profile_id = (select auth.uid())
        and theirs.profile_id = profiles.id
    )
  );

create policy profiles_insert_self on public.profiles
  for insert
  with check (id = (select auth.uid()));

create policy profiles_update_self on public.profiles
  for update
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy events_select_members on public.events
  for select
  using ((select public.is_event_member(id)));

create policy events_insert_owner on public.events
  for insert
  with check (owner_id = (select auth.uid()));

create policy events_update_managers on public.events
  for update
  using ((select public.can_manage_event(id)))
  with check ((select public.can_manage_event(id)));

create policy event_members_select_members on public.event_members
  for select
  using ((select public.is_event_member(event_id)));

create policy event_members_insert_owner_or_self_owner_bootstrap on public.event_members
  for insert
  with check (
    (profile_id = (select auth.uid()) and role = 'owner' and (select public.is_event_owner(event_id)))
    or (select public.can_manage_event(event_id))
  );

create policy event_members_update_managers on public.event_members
  for update
  using ((select public.can_manage_event(event_id)))
  with check ((select public.can_manage_event(event_id)));

create policy venues_select_members on public.venues
  for select
  using ((select public.is_event_member(event_id)));

create policy venues_write_managers on public.venues
  for all
  using ((select public.can_manage_event(event_id)))
  with check ((select public.can_manage_event(event_id)));

create policy responsibilities_select_members on public.responsibilities
  for select
  using ((select public.is_event_member(event_id)));

create policy responsibilities_insert_managers on public.responsibilities
  for insert
  with check ((select public.can_manage_event(event_id)));

create policy responsibilities_update_owner_or_managers on public.responsibilities
  for update
  using ((select public.can_manage_event(event_id)) or owner_id = (select auth.uid()))
  with check ((select public.can_manage_event(event_id)) or owner_id = (select auth.uid()));

create policy checklist_select_members on public.checklist_items
  for select
  using (
    exists (
      select 1 from public.responsibilities r
      where r.id = responsibility_id
        and (select public.is_event_member(r.event_id))
    )
  );

create policy checklist_insert_manager on public.checklist_items
  for insert
  with check (
    exists (
      select 1 from public.responsibilities r
      where r.id = responsibility_id
        and (select public.can_manage_event(r.event_id))
    )
  );

create policy checklist_update_assignee_or_manager on public.checklist_items
  for update
  using (
    exists (
      select 1 from public.responsibilities r
      where r.id = responsibility_id
        and ((select public.can_manage_event(r.event_id)) or r.owner_id = (select auth.uid()))
    )
  )
  with check (
    exists (
      select 1 from public.responsibilities r
      where r.id = responsibility_id
        and ((select public.can_manage_event(r.event_id)) or r.owner_id = (select auth.uid()))
    )
  );

create policy checklist_delete_manager on public.checklist_items
  for delete
  using (
    exists (
      select 1 from public.responsibilities r
      where r.id = responsibility_id
        and (select public.can_manage_event(r.event_id))
    )
  );

create policy meals_select_members on public.meals
  for select
  using ((select public.is_event_member(event_id)));

create policy meals_insert_manager on public.meals
  for insert
  with check ((select public.can_manage_event(event_id)));

create policy meals_update_owner_or_manager on public.meals
  for update
  using ((select public.can_manage_event(event_id)) or owner_id = (select auth.uid()))
  with check ((select public.can_manage_event(event_id)) or owner_id = (select auth.uid()));

create policy meals_delete_manager on public.meals
  for delete
  using ((select public.can_manage_event(event_id)));

create policy meal_items_select_members on public.meal_items
  for select
  using (
    exists (
      select 1 from public.meals m
      where m.id = meal_id
        and (select public.is_event_member(m.event_id))
    )
  );

create policy meal_items_insert_meal_owner_or_manager on public.meal_items
  for insert
  with check (
    exists (
      select 1 from public.meals m
      where m.id = meal_id
        and ((select public.can_manage_event(m.event_id)) or m.owner_id = (select auth.uid()))
    )
  );

create policy meal_items_update_meal_owner_or_manager on public.meal_items
  for update
  using (
    exists (
      select 1 from public.meals m
      where m.id = meal_id
        and ((select public.can_manage_event(m.event_id)) or m.owner_id = (select auth.uid()))
    )
  )
  with check (
    exists (
      select 1 from public.meals m
      where m.id = meal_id
        and ((select public.can_manage_event(m.event_id)) or m.owner_id = (select auth.uid()))
    )
  );

create policy meal_items_delete_manager on public.meal_items
  for delete
  using (
    exists (
      select 1 from public.meals m
      where m.id = meal_id
        and (select public.can_manage_event(m.event_id))
    )
  );

create policy supply_items_select_members on public.supply_items
  for select
  using ((select public.is_event_member(event_id)));

create policy supply_items_insert_manager on public.supply_items
  for insert
  with check ((select public.can_manage_event(event_id)));

create policy supply_items_update_assignee_or_manager on public.supply_items
  for update
  using ((select public.can_manage_event(event_id)) or assigned_profile_id = (select auth.uid()))
  with check ((select public.can_manage_event(event_id)) or assigned_profile_id = (select auth.uid()));

create policy supply_items_delete_manager on public.supply_items
  for delete
  using ((select public.can_manage_event(event_id)));

create policy expenses_select_members on public.expenses
  for select
  using ((select public.is_event_member(event_id)));

create policy expenses_insert_member_self_paid on public.expenses
  for insert
  with check ((select public.is_event_member(event_id)) and paid_by_profile_id = (select auth.uid()));

create policy expenses_update_payer_or_manager on public.expenses
  for update
  using ((select public.can_manage_event(event_id)) or paid_by_profile_id = (select auth.uid()))
  with check ((select public.can_manage_event(event_id)) or paid_by_profile_id = (select auth.uid()));

create policy expense_splits_select_event_members on public.expense_splits
  for select
  using (
    exists (
      select 1 from public.expenses e
      where e.id = expense_id
        and (select public.is_event_member(e.event_id))
    )
  );

create policy expense_splits_insert_managers on public.expense_splits
  for insert
  with check (
    exists (
      select 1 from public.expenses e
      where e.id = expense_id
        and (select public.can_manage_event(e.event_id))
    )
  );

create policy expense_splits_update_managers on public.expense_splits
  for update
  using (
    exists (
      select 1 from public.expenses e
      where e.id = expense_id
        and (select public.can_manage_event(e.event_id))
    )
  )
  with check (
    exists (
      select 1 from public.expenses e
      where e.id = expense_id
        and (select public.can_manage_event(e.event_id))
    )
  );

create policy expense_splits_delete_managers on public.expense_splits
  for delete
  using (
    exists (
      select 1 from public.expenses e
      where e.id = expense_id
        and (select public.can_manage_event(e.event_id))
    )
  );

create policy notes_select_visible on public.notes
  for select
  using (
    (visibility = 'event_board' and (select public.is_event_member(event_id)))
    or author_id = (select auth.uid())
    or (visibility = 'owner_only' and (select public.can_manage_event(event_id)))
    or exists (
      select 1 from public.note_recipients nr
      where nr.note_id = notes.id
        and nr.profile_id = (select auth.uid())
    )
  );

create policy notes_insert_members on public.notes
  for insert
  with check ((select public.is_event_member(event_id)) and author_id = (select auth.uid()));

create policy note_recipients_select_related on public.note_recipients
  for select
  using (
    profile_id = (select auth.uid())
    or exists (
      select 1 from public.notes n
      where n.id = note_id
        and n.author_id = (select auth.uid())
    )
  );

create policy note_recipients_insert_note_author on public.note_recipients
  for insert
  with check (
    exists (
      select 1 from public.notes n
      where n.id = note_id
        and n.author_id = (select auth.uid())
    )
  );

create policy event_updates_select_members on public.event_updates
  for select
  using ((select public.is_event_member(event_id)));

create policy event_updates_insert_members on public.event_updates
  for insert
  with check ((select public.is_event_member(event_id)) and actor_id = (select auth.uid()));
