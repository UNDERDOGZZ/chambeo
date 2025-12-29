-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- Public profile view (limited fields)
CREATE OR REPLACE VIEW public_profiles AS
SELECT id, full_name, photo_url, rating_avg, rating_count, district
FROM profiles;

REVOKE ALL ON profiles FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON profiles TO authenticated;
GRANT SELECT ON public_profiles TO anon, authenticated;

-- PROFILES policies
DROP POLICY IF EXISTS profiles_select_self ON profiles;
CREATE POLICY profiles_select_self
  ON profiles
  FOR SELECT
  USING (id = auth.uid());

DROP POLICY IF EXISTS profiles_insert_self ON profiles;
CREATE POLICY profiles_insert_self
  ON profiles
  FOR INSERT
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS profiles_update_self ON profiles;
CREATE POLICY profiles_update_self
  ON profiles
  FOR UPDATE
  USING (id = auth.uid());

-- JOBS policies
DROP POLICY IF EXISTS jobs_select_client ON jobs;
CREATE POLICY jobs_select_client
  ON jobs
  FOR SELECT
  USING (client_id = auth.uid());

DROP POLICY IF EXISTS jobs_select_open_for_workers ON jobs;
CREATE POLICY jobs_select_open_for_workers
  ON jobs
  FOR SELECT
  USING (status = 'open');

DROP POLICY IF EXISTS jobs_insert_client ON jobs;
CREATE POLICY jobs_insert_client
  ON jobs
  FOR INSERT
  WITH CHECK (client_id = auth.uid());

DROP POLICY IF EXISTS jobs_update_client ON jobs;
CREATE POLICY jobs_update_client
  ON jobs
  FOR UPDATE
  USING (client_id = auth.uid());

DROP POLICY IF EXISTS jobs_delete_client ON jobs;
CREATE POLICY jobs_delete_client
  ON jobs
  FOR DELETE
  USING (client_id = auth.uid());

-- JOB_OFFERS policies
DROP POLICY IF EXISTS job_offers_select_client ON job_offers;
CREATE POLICY job_offers_select_client
  ON job_offers
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM jobs
      WHERE jobs.id = job_offers.job_id
        AND jobs.client_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS job_offers_select_worker ON job_offers;
CREATE POLICY job_offers_select_worker
  ON job_offers
  FOR SELECT
  USING (worker_id = auth.uid());

DROP POLICY IF EXISTS job_offers_insert_worker ON job_offers;
CREATE POLICY job_offers_insert_worker
  ON job_offers
  FOR INSERT
  WITH CHECK (
    worker_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM jobs
      WHERE jobs.id = job_offers.job_id
        AND jobs.status = 'open'
        AND jobs.client_id <> auth.uid()
    )
  );

DROP POLICY IF EXISTS job_offers_update_withdrawn ON job_offers;
CREATE POLICY job_offers_update_withdrawn
  ON job_offers
  FOR UPDATE
  USING (worker_id = auth.uid())
  WITH CHECK (worker_id = auth.uid() AND status = 'withdrawn');

-- JOB_ASSIGNMENTS policies
DROP POLICY IF EXISTS job_assignments_select_participants ON job_assignments;
CREATE POLICY job_assignments_select_participants
  ON job_assignments
  FOR SELECT
  USING (client_id = auth.uid() OR worker_id = auth.uid());

DROP POLICY IF EXISTS job_assignments_insert_client ON job_assignments;
CREATE POLICY job_assignments_insert_client
  ON job_assignments
  FOR INSERT
  WITH CHECK (
    client_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM jobs
      WHERE jobs.id = job_assignments.job_id
        AND jobs.client_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS job_assignments_update_participants ON job_assignments;
CREATE POLICY job_assignments_update_participants
  ON job_assignments
  FOR UPDATE
  USING (client_id = auth.uid() OR worker_id = auth.uid());

-- MESSAGES policies
DROP POLICY IF EXISTS messages_select_participants ON messages;
CREATE POLICY messages_select_participants
  ON messages
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM job_assignments
      WHERE job_assignments.job_id = messages.job_id
        AND (job_assignments.client_id = auth.uid()
          OR job_assignments.worker_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS messages_insert_participants ON messages;
CREATE POLICY messages_insert_participants
  ON messages
  FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM job_assignments
      WHERE job_assignments.job_id = messages.job_id
        AND (job_assignments.client_id = auth.uid()
          OR job_assignments.worker_id = auth.uid())
    )
  );

-- RATINGS policies
DROP POLICY IF EXISTS ratings_select_participants ON ratings;
CREATE POLICY ratings_select_participants
  ON ratings
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM jobs
      WHERE jobs.id = ratings.job_id
        AND jobs.status = 'done'
        AND (jobs.client_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM job_assignments
            WHERE job_assignments.job_id = jobs.id
              AND job_assignments.worker_id = auth.uid()
          ))
    )
  );

DROP POLICY IF EXISTS ratings_insert_participants ON ratings;
CREATE POLICY ratings_insert_participants
  ON ratings
  FOR INSERT
  WITH CHECK (
    rater_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM jobs
      WHERE jobs.id = ratings.job_id
        AND jobs.status = 'done'
        AND (jobs.client_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM job_assignments
            WHERE job_assignments.job_id = jobs.id
              AND job_assignments.worker_id = auth.uid()
          ))
    )
  );
