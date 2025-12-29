-- updated_at trigger for profiles
CREATE OR REPLACE FUNCTION set_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS profiles_set_updated_at ON profiles;
CREATE TRIGGER profiles_set_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION set_profiles_updated_at();

-- rating aggregate trigger
CREATE OR REPLACE FUNCTION update_profile_rating_stats()
RETURNS TRIGGER AS $$
DECLARE
  avg_score numeric(3,2);
  total_count integer;
BEGIN
  SELECT COALESCE(ROUND(AVG(score)::numeric, 2), 0), COUNT(*)
    INTO avg_score, total_count
    FROM ratings
   WHERE ratee_id = NEW.ratee_id;

  UPDATE profiles
     SET rating_avg = avg_score,
         rating_count = total_count,
         updated_at = now()
   WHERE id = NEW.ratee_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ratings_update_profile_stats ON ratings;
CREATE TRIGGER ratings_update_profile_stats
AFTER INSERT ON ratings
FOR EACH ROW
EXECUTE FUNCTION update_profile_rating_stats();
